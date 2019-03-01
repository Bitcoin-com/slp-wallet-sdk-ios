//
//  SLPWallet.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import BitcoinKit
import RxSwift
import RxCocoa

public protocol SLPWalletDelegate {
    func onUpdatedToken(_ token: [String:SLPToken])
}

public class SLPWallet {
    
    fileprivate static let bag = DisposeBag()
    
    fileprivate let privKey: PrivateKey
    fileprivate let network: Network
    fileprivate var tokens: [String:SLPToken]
    fileprivate var utxos: [SLPUTXO]
    
    public let mnemonic: String
    public let cashAddress: String
    public let slpAddress: String
    
    public var delegate: SLPWalletDelegate?
    
    public lazy var scheduler: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: 10)
        t.setEventHandler(handler: { [weak self] in
            self?.fetchTokens()
                .subscribe()
                .disposed(by: SLPWallet.bag)
        })
        return t
    }()
    
    public convenience init(_ network: Network) {
        let mnemonic = try! Mnemonic.generate()
        self.init(mnemonic.joined(separator: ","), network: network)
    }
    
    public init(_ mnemonic: String, network: Network) {
        let seed = Mnemonic.seed(mnemonic: mnemonic.components(separatedBy: ","))
        let hdPrivKey = HDPrivateKey(seed: seed, network: network)
        
        
        let xPrivKey = try! hdPrivKey.derived(at: 44, hardened: true).derived(at: 0).derived(at: 0)
        let privKey = try! xPrivKey.derived(at: UInt32(0)).derived(at: UInt32(0)).privateKey()
        
        
        print(privKey.toWIF())
        
        self.mnemonic = mnemonic
        self.privKey = privKey
        self.network = network
        self.cashAddress = privKey.publicKey().toCashaddr().cashaddr
        
        let addressData: Data = [0] + privKey.publicKey().toCashaddr().data
        
        // Quick way to do it, @angel is working on building it in BitcoinKit
        self.slpAddress = Bech32.encode(addressData, prefix: network == .mainnet ? "simpleledger" : "slptest")
        self.tokens = [String:SLPToken]()
        self.utxos = [SLPUTXO]()
    }
    
    public func fetchTokens() -> Single<[String:SLPToken]> {
        return Single<[String:SLPToken]>.create { single in
            RestService
                .fetchUTXOs(self.cashAddress)
                .subscribe({ event in
                    switch event {
                    case .success(let utxo):
                        let txids = utxo
                            .utxos
                            .compactMap { $0.txid }
                        
                        RestService
                            .fetchTxDetails(txids)
                            .subscribe({ event in
                                switch event {
                                case .success(let txs):
                                    
                                    var newTokens = [String:SLPToken]()
                                    
                                    txs.forEach({ tx in
                                        
                                        // TODO: Parse the tx in another place
                                        let script = Script(hex: tx.vout[0].scriptPubKey.hex)
                                        
                                        var voutToTokenQty = [Int]()
                                        var tokenId: String = ""
                                        var currentToken: SLPToken?
                                        
                                        if var chunks = script?.scriptChunks
                                            , chunks.removeFirst().opCode == .OP_RETURN {
                                            
                                            // 0 : lokad id 4 bytes ASCII
                                            // Good
                                            guard let lokadId = String(data: chunks[0].chunkData.clean(), encoding: String.Encoding.ascii) else {
                                                return
                                            }
                                            
                                            if lokadId == "SLP" {
                                                var newToken = SLPToken()
                                                
                                                // 1 : token_type 1 bytes Integer
                                                // Good
                                                let tokenType = chunks[1].chunkData.clean().uint8
                                                
                                                // 2 : transaction_type 4 bytes ASCII
                                                // Good
                                                guard let transactionType = String(data: chunks[2].chunkData.clean(), encoding: String.Encoding.ascii) else {
                                                    return
                                                }

                                                if transactionType == SLPTransactionType.GENESIS.rawValue {
                                                    
                                                    // Genesis => Txid
                                                    newToken.tokenId = tx.txid
                                                    
                                                    // 3 : token_ticker UTF8
                                                    // Good
                                                    guard let tokenTicker = String(data: chunks[3].chunkData.clean(), encoding: String.Encoding.utf8) else {
                                                        return
                                                    }
                                                    newToken.tokenTicker = tokenTicker
                                                    
                                                    // 4 : token_name UTF8
                                                    // Good
                                                    guard let tokenName = String(data: chunks[4].chunkData.clean(), encoding: String.Encoding.utf8) else {
                                                        return
                                                    }
                                                    newToken.tokenName = tokenName
                                                    
                                                    // 8 : decimal 1 Byte
                                                    // Good
                                                    guard let decimal = Int(chunks[7].chunkData.clean().hex, radix: 16) else {
                                                        return
                                                    }
                                                    newToken.decimal = decimal
                                                    
                                                    // 3 : token_id 32 bytes  hex
                                                    // Good
                                                    guard let balance = Int(chunks[9].chunkData.clean().hex, radix: 16) else {
                                                        return
                                                    }
                                                    voutToTokenQty.append(balance)
                                                    
                                                } else if transactionType == SLPTransactionType.SEND.rawValue {
                                                    
                                                    // 3 : token_id 32 bytes  hex
                                                    // Good
                                                    newToken.tokenId = chunks[3].chunkData.clean().hex
                                                    
                                                    // 4 to .. : token_output_quantity 1..19
                                                    for i in 4...chunks.count - 1 {
                                                        guard let balance = Int(chunks[i].chunkData.clean().hex, radix: 16) else {
                                                            return
                                                        }
                                                        voutToTokenQty.append(balance)
                                                    }
                                                }
                                                
                                                // Set the good current token & add the new token if it is needed :)
                                                if let tId = newToken.tokenId {
                                                    if let t = self.tokens[tId] {
                                                        currentToken = t
                                                    } else {
                                                        newTokens[tId] = newToken
                                                        currentToken = newToken
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                        // Loop the UTXO
                                        // If my utxos
                                        // If UTXO owns token
                                        // Save the utxo in the Token + Amount of token
                                        // else
                                        // Save the utxo in my wallet
                                        for i in 0...tx.vout.count - 1 {
                                            let vout = tx.vout[i]
                                            let script = Script(hex: vout.scriptPubKey.hex)
                                            
                                            // If OP_RETURN, I drop this UTXO
                                            if script?.scriptChunks[i].opCode == .OP_RETURN {
                                                continue
                                            }
                                            
                                            // If my UTXO
                                            if utxo.scriptPubKey == vout.scriptPubKey.hex {
                                                // If UTXO owns Token
                                                if voutToTokenQty.count + 1 > i
                                                    , currentToken != nil
                                                {
                                                    if currentToken?.utxos.filter({ utxo -> Bool in
                                                        return utxo.txid == tx.txid && utxo.index == i
                                                    }).count == 0 {
                                                        let rawTokenQty = voutToTokenQty[i - 1]
                                                        let tokenUTXO = TokenUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: self.cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: i, rawTokenQty: rawTokenQty)
                                                        currentToken?.utxos.append(tokenUTXO)
                                                    }
                                                } else {
                                                    if self.utxos.filter({ utxo -> Bool in
                                                        return utxo.txid == tx.txid && utxo.index == i
                                                    }).count == 0 {
                                                        let utxo = SLPUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: self.cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: i)
                                                        self.utxos.append(utxo)
                                                    }
                                                }
                                            }
                                        }
                                    })
                                    
                                    Observable
                                        .zip(newTokens.map { self.addToken($1).asObservable() })
                                        .subscribe({ event in
                                            switch event {
                                            case .next(let _): break
                                                // Nothing interesting to do for now here
                                            case .completed:
                                                self.delegate?.onUpdatedToken(self.tokens)
                                                single(.success(self.tokens))
                                            case .error(let error):
                                                single(.error(error))
                                            }
                                        })
                                        .disposed(by: SLPWallet.bag)
                                    
                                case .error(let error):
                                    single(.error(error))
                                }
                            })
                            .disposed(by: SLPWallet.bag)
                    case .error(let error):
                        single(.error(error))
                    }
                })
                .disposed(by: SLPWallet.bag)
            return Disposables.create()
        }
    }
    
    enum SLPWalletError : Error {
        case TOKEN_ID
    }
    
    public func addToken(_ token: SLPToken) -> Single<SLPToken> {
        return Single<SLPToken>.create { single in
            guard let tokenId = token.tokenId else {
                single(.error(SLPWalletError.TOKEN_ID))
                return Disposables.create()
            }
            RestService
                .fetchTxDetails([tokenId])
                .subscribe({ response in
                    switch response {
                    case.success(let txs):
                        txs.forEach({ tx in
                            
                            let script = Script(hex: tx.vout[0].scriptPubKey.hex)
                            guard var chunks = script?.scriptChunks
                                , chunks.removeFirst().opCode == .OP_RETURN else {
                                    return
                            }
                            
                            // 2 : transaction_type 4 bytes ASCII
                            // Good
                            var chunk = chunks[2].chunkData.clean()
                            guard let transactionType = String(data: chunk, encoding: String.Encoding.ascii)
                                , transactionType == "GENESIS" else {
                                    return
                            }
                            
                            // 3 : token_ticker UTF8
                            // Good
                            chunk = chunks[3].chunkData.clean()
                            guard let tokenTicker = String(data: chunk, encoding: String.Encoding.utf8) else {
                                return
                            }
                            token.tokenTicker = tokenTicker
                            
                            // 4 : token_name UTF8
                            // Good
                            chunk = chunks[4].chunkData.clean()
                            guard let tokenName = String(data: chunk, encoding: String.Encoding.utf8) else {
                                return
                            }
                            token.tokenName = tokenName
                            
                            // 8 : decimal 1 Byte
                            // Good
                            chunk = chunks[7].chunkData.clean()
                            guard let decimal = Int(chunk.hex, radix: 16) else {
                                return
                            }
                            token.decimal = decimal
                        })
                        
                        // Add the token in the list
                        self.tokens[tokenId] = token
                        
                        single(.success(token))
                    case .error(let error):
                        single(.error(error))
                    }
                })
                .disposed(by: SLPWallet.bag)
            return Disposables.create()
        }
    }
    
}


