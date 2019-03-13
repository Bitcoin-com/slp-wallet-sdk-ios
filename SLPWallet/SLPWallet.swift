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
import KeychainAccess

public protocol SLPWalletDelegate {
    func onUpdatedToken(_ token: SLPToken)
}

public class SLPWallet {
    
    enum SLPWalletError : String, Error {
        case TOKEN_ID_REQUIRED
        case MNEMONIC_NOT_FOUND
    }
    
    fileprivate static let bag = DisposeBag()
    fileprivate static let storageProvider = StorageProvider()
    
    internal let _mnemonic: [String]
    internal let _cashAddress: String
    internal let _slpAddress: String
    internal var _tokens: [String:SLPToken]
    internal let _privKey: PrivateKey
    
    internal let _network: Network
    internal var _utxos: [SLPWalletUTXO]
    
    internal var privKey: PrivateKey {
        get { return _privKey }
    }
    
    public var utxos: [SLPWalletUTXO] {
        get { return _utxos }
    }
    
    public var mnemonic: [String] {
        get { return _mnemonic }
    }
    public var cashAddress: String {
        get { return _cashAddress }
    }
    public var slpAddress: String {
        get { return _slpAddress }
    }
    public var tokens: [String:SLPToken] {
        get { return _tokens }
    }
    
    public var delegate: SLPWalletDelegate?
    
    public var schedulerInterval: Double = 20 {
        didSet {
            scheduler.schedule(deadline: .now(), repeating: schedulerInterval)
        }
    }
    public lazy var scheduler: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: schedulerInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.fetchTokens()
                .subscribe()
                .disposed(by: SLPWallet.bag)
        })
        return t
    }()
    
    public convenience init(_ network: Network) throws {
        try self.init(network, force: false)
    }
    
    public convenience init(_ network: Network, force: Bool = false) throws {
        if force {
            let mnemonic = try Mnemonic.generate()
            let mnemonicStr = mnemonic.joined(separator: " ")
            try self.init(mnemonicStr, network: network)
        } else {
            // Get in keychain
            guard let mnemonic = try SLPWallet.storageProvider.getString("mnemonic") else {
                try self.init(network, force: true)
                return
            }
            try self.init(mnemonic, network: network)
        }
    }
    
    public init(_ mnemonic: String, network: Network) throws {
        
        // Store in keychain
        try SLPWallet.storageProvider.setString(mnemonic, key: "mnemonic")
        
        // Then go forward
        let arrayOfwords = mnemonic.components(separatedBy: " ")
        
        let seed = Mnemonic.seed(mnemonic: mnemonic.components(separatedBy: " "))
        let hdPrivKey = HDPrivateKey(seed: seed, network: network)
        
        let xPrivKey = try! hdPrivKey.derived(at: 44, hardened: true).derived(at: 245, hardened: true).derived(at: 0, hardened: true)
        let privKey = try! xPrivKey.derived(at: UInt32(0)).derived(at: UInt32(0)).privateKey()
        
        self._network = network
        
        self._mnemonic = arrayOfwords
        self._privKey = privKey
        self._cashAddress = privKey.publicKey().toCashaddr().cashaddr
        
        let addressData: Data = [0] + privKey.publicKey().toCashaddr().data
        
        // TODO: Quick way to do it, @angel is working on building it in BitcoinKit
        
        // Not working
        // self._slpAddress = privKey.publicKey().toSlpaddr().slpaddr
        self._slpAddress = Bech32.encode(addressData, prefix: network == .mainnet ? "simpleledger" : "slptest")
        self._tokens = [String:SLPToken]()
        self._utxos = [SLPWalletUTXO]()
    }
}

public extension SLPWallet {
    
    public func getGas() -> Int {
        return _utxos.reduce(0, { $0 + $1.satoshis })
    }
    
    public func fetchTokens() -> Single<[String:SLPToken]> {
        return Single<[String:SLPToken]>.create { single in
            RestService
                .fetchUTXOs(self.cashAddress)
                .subscribe({ event in
                    switch event {
                    case .success(let utxo):
                        let requests = utxo
                            .utxos
                            .compactMap { $0.txid }
                            .removeDuplicates()
                            .chunk(20)
                        
                        Observable
                            .zip(requests
                                .map { RestService
                                    .fetchTxDetails($0)
                                    .asObservable() })
                            .subscribe({ event in
                                switch event {
                                case .next(let response):
                                    
                                    let txs = response.flatMap({ $0 })
                                    
                                    var updatedTokens = [String:SLPToken]()
                                    var updatedUTXOs = [SLPWalletUTXO]()
                                    
                                    txs.forEach({ tx in
                                        
                                        // TODO: Parse the tx in another place
                                        let script = Script(hex: tx.vout[0].scriptPubKey.hex)
                                        
                                        var voutToTokenQty = [Int]()
                                        voutToTokenQty.append(0) // To have the same mapping with the vouts
                                        
                                        var currentToken = SLPToken()
                                        
                                        if var chunks = script?.scriptChunks
                                            , chunks.removeFirst().opCode == .OP_RETURN {
                                            
                                            // 0 : lokad id 4 bytes ASCII
                                            // Good
                                            guard let lokadId = chunks[0].chunkData.removeLeft().removeRight().stringASCII else {
                                                return
                                            }
                                            
                                            if lokadId == "SLP" {
                                                
                                                // 1 : token_type 1 bytes Integer
                                                // Good
                                                var chunk = chunks[1].chunkData.removeLeft()
                                                let tokenType = chunk.uint8
                                                
                                                // 2 : transaction_type 4 bytes ASCII
                                                // Good
                                                chunk = chunks[2].chunkData.removeLeft()
                                                guard let transactionType = chunks[2].chunkData.removeLeft().stringASCII else {
                                                    return
                                                }
                                                
                                                if transactionType == SLPTransactionType.GENESIS.rawValue {
                                                    
                                                    // Genesis => Txid
                                                    let tokenId = tx.txid
                                                    currentToken.tokenId = tokenId
                                                    
                                                    // If the token is already found, continue to work on it
                                                    if let token = updatedTokens[tokenId] {
                                                        currentToken = token
                                                    }
                                                    
                                                    // 3 : token_ticker UTF8
                                                    // Good
                                                    chunk = chunks[3].chunkData.removeLeft()
                                                    guard let tokenTicker = chunk.stringUTF8 else {
                                                        return
                                                    }
                                                    currentToken.tokenTicker = tokenTicker
                                                    
                                                    // 4 : token_name UTF8
                                                    // Good
                                                    chunk = chunks[4].chunkData.removeLeft()
                                                    guard let tokenName = chunk.stringUTF8 else {
                                                        return
                                                    }
                                                    currentToken.tokenName = tokenName
                                                    
                                                    // 8 : decimal 1 Byte
                                                    // Good
                                                    chunk = chunks[7].chunkData.removeLeft()
                                                    guard let decimal = Int(chunk.hex, radix: 16) else {
                                                        return
                                                    }
                                                    currentToken.decimal = decimal
                                                    
                                                    // 3 : token_id 32 bytes  hex
                                                    // Good
                                                    chunk = chunks[9].chunkData.removeLeft()
                                                    guard let balance = Int(chunk.hex, radix: 16) else {
                                                        return
                                                    }
                                                    voutToTokenQty.append(balance)
                                                    
                                                } else if transactionType == SLPTransactionType.SEND.rawValue {
                                                    
                                                    // 3 : token_id 32 bytes  hex
                                                    // Good
                                                    chunk = chunks[3].chunkData.removeLeft()
                                                    let tokenId = chunk.hex
                                                    currentToken.tokenId = tokenId
                                                    
                                                    // If the token is already found, continue to work on it
                                                    if let token = updatedTokens[tokenId] {
                                                        currentToken = token
                                                    }
                                                    
                                                    // 4 to .. : token_output_quantity 1..19
                                                    for i in 4...chunks.count - 1 {
                                                        chunk = chunks[i].chunkData.removeLeft()
                                                        if let balance = Int(chunk.hex, radix: 16) {
                                                            voutToTokenQty.append(balance)
                                                        } else {
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Get the vouts that we are interested in
                                        let vouts = utxo.utxos.filter({ return $0.txid == tx.txid })
                                        vouts.forEach({ utxo in
                                            let vout = tx.vout[utxo.vout]
                                            
                                            guard vout.n < voutToTokenQty.count else {
                                                // UTXO without token
                                                let utxo = SLPWalletUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: self.cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n)
                                                updatedUTXOs.append(utxo)
                                                return
                                            }
                                            
                                            // UTXO with a token
                                            let rawTokenQty = voutToTokenQty[vout.n]
                                            let tokenUTXO = SLPTokenUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: self.cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n, rawTokenQty: rawTokenQty)
                                            currentToken.addUTXO(tokenUTXO)
                                        })
                                        
                                        // If first time, map the token in updatedTokens
                                        if let tId = currentToken.tokenId {
                                            if updatedTokens[tId] == nil {
                                                updatedTokens[tId] = currentToken
                                            }
                                        }
                                    })
                                    
                                    // Update the UTXOs used as gas :)
                                    self._utxos = updatedUTXOs
                                    
                                    // Check which one is new and need to get the info from Genesis
                                    var newTokens = [SLPToken]()
                                    updatedTokens.forEach({ tokenId, token in
                                        guard let t = self._tokens[tokenId] else {
                                            newTokens.append(token)
                                            return
                                        }
                                        
                                        var hasChanged = false
                                        if t.utxos.count != token.utxos.count {
                                            hasChanged = true
                                        } else {
                                            let diff = t.utxos
                                                .enumerated()
                                                .filter({ $0.element != token.utxos[$0.offset] })
                                            
                                            if diff.count > 0 {
                                                hasChanged = true
                                            }
                                        }
                                        
                                        // If it has changed, notify
                                        if hasChanged {
                                            self.delegate?.onUpdatedToken(t)
                                        }
                                    })
                                    
                                    Observable
                                        .zip(newTokens.map { self.addToken($0).asObservable() })
                                        .subscribe({ event in
                                            switch event {
                                            case .next(let tokens):
                                                tokens.forEach({ self.delegate?.onUpdatedToken($0) })
                                            case .completed:
                                                single(.success(self._tokens))
                                            case .error(let error):
                                                single(.error(error))
                                            }
                                        })
                                        .disposed(by: SLPWallet.bag)
                                    
                                case .error(let error):
                                    single(.error(error))
                                case .completed: break
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
    
    public func sendToken(_ tokenId: String, amount: Double, toAddress: String) -> Single<String> {
        return Single<String>.create { single in
            self.fetchTokens()
                .subscribe(onSuccess: { _ in
                    do {
                        let rawTx = try SLPTransactionBuilder.build(self, tokenId: tokenId, amount: amount, toAddress: toAddress)
                        
                        RestService
                            .broadcast(rawTx)
                            .subscribe({ response in
                                switch response {
                                case.success(let txid):
                                    single(.success(txid))
                                case .error(let error):
                                    single(.error(error))
                                }
                            })
                            .disposed(by: SLPWallet.bag)
                    } catch (let error) {
                        single(.error(error))
                    }
                }, onError: { error in
                    single(.error(error))
                })
                .disposed(by: SLPWallet.bag)
            
            return Disposables.create()
        }
    }
    
    public func addToken(_ token: SLPToken) -> Single<SLPToken> {
        return Single<SLPToken>.create { single in
            guard let tokenId = token.tokenId else {
                single(.error(SLPWalletError.TOKEN_ID_REQUIRED))
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
                            var chunk = chunks[2].chunkData.removeLeft()
                            guard let transactionType = chunk.stringASCII
                                , transactionType == "GENESIS" else {
                                    return
                            }
                            
                            // 3 : token_ticker UTF8
                            // Good
                            chunk = chunks[3].chunkData.removeLeft()
                            guard let tokenTicker = chunk.stringUTF8 else {
                                return
                            }
                            token.tokenTicker = tokenTicker
                            
                            // 4 : token_name UTF8
                            // Good
                            chunk = chunks[4].chunkData.removeLeft()
                            guard let tokenName = chunk.stringUTF8 else {
                                return
                            }
                            token.tokenName = tokenName
                            
                            // 8 : decimal 1 Byte
                            // Good
                            chunk = chunks[7].chunkData.removeLeft()
                            guard let decimal = Int(chunk.hex, radix: 16) else {
                                return
                            }
                            token.decimal = decimal
                        })
                        
                        // Add the token in the list
                        self._tokens[tokenId] = token
                        
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


