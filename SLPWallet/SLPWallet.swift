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

public enum SLPWalletError : String, Error {
    case TOKEN_ID_REQUIRED
    case MNEMONIC_NOT_FOUND
    case PRIVKEY_NOT_FOUND
}

public protocol SLPWalletDelegate {
    func onUpdatedToken(_ token: SLPToken)
}

public class SLPWallet {
    
    fileprivate static let bag = DisposeBag()
    fileprivate static let storageProvider = StorageProvider()
    
    let _mnemonic: [String]
    var _tokens: [String:SLPToken]
    
    let _BCHAccount: Account
    let _SLPAccount: Account
    
    let _slpAddress: String
    
    let _network: Network
    var _utxos: [SLPWalletUTXO]
    
    var BCHAccount: Account {
        get { return _BCHAccount }
    }
    
    var SLPAccount: Account {
        get { return _SLPAccount }
    }
    
    public var utxos: [SLPWalletUTXO] {
        get { return _utxos }
    }
    
    public var mnemonic: [String] {
        get { return _mnemonic }
    }
    public var cashAddress: String {
        get { return _BCHAccount.cashAddress }
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
            scheduler.cancel()
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
        
        // 145
        var xPrivKey = try! hdPrivKey.derived(at: 44, hardened: true).derived(at: 145, hardened: true).derived(at: 0, hardened: true)
        var privKey = try! xPrivKey.derived(at: UInt32(0)).derived(at: UInt32(0)).privateKey()
        
        self._BCHAccount = Account(privKey: privKey, cashAddress: privKey.publicKey().toCashaddr().cashaddr)
        
        // 245
        xPrivKey = try! hdPrivKey.derived(at: 44, hardened: true).derived(at: 245, hardened: true).derived(at: 0, hardened: true)
        privKey = try! xPrivKey.derived(at: UInt32(0)).derived(at: UInt32(0)).privateKey()
        
        self._SLPAccount = Account(privKey: privKey, cashAddress: privKey.publicKey().toCashaddr().cashaddr)
        
        self._mnemonic = arrayOfwords
        self._network = network
        
        // TODO: Quick way to do it, @angel is working on building it in BitcoinKit
        // Not working
        // self._slpAddress = privKey.publicKey().toSlpaddr().slpaddr
        let addressData: Data = [0] + privKey.publicKey().toCashaddr().data
        self._slpAddress = Bech32.encode(addressData, prefix: network == .mainnet ? "simpleledger" : "slptest")
        self._tokens = [String:SLPToken]()
        self._utxos = [SLPWalletUTXO]()
    }
}

public extension SLPWallet {
    
    public func getGas() -> Int {
        return _utxos.reduce(0, { $0 + Int($1.satoshis) })
    }
    
    public func fetchTokens() -> Single<[String:SLPToken]> {
        
        let cashAddresses = [BCHAccount.cashAddress, SLPAccount.cashAddress]
        
        return Single<[String:SLPToken]>.create { single in
            RestService
                .fetchUTXOs(cashAddresses)
                .subscribe({ event in
                    switch event {
                    case .success(let rawUtxos):
                        let utxos = rawUtxos
                            .flatMap { $0.utxos }
                        let requests = utxos
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
                                        var mintVout = 0
                                        
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
                                                    currentToken._tokenId = tokenId
                                                    
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
                                                    currentToken._tokenTicker = tokenTicker
                                                    
                                                    // 4 : token_name UTF8
                                                    // Good
                                                    chunk = chunks[4].chunkData.removeLeft()
                                                    guard let tokenName = chunk.stringUTF8 else {
                                                        return
                                                    }
                                                    currentToken._tokenName = tokenName
                                                    
                                                    // 7 : decimal 1 Byte
                                                    // Good
                                                    chunk = chunks[7].chunkData.removeLeft()
                                                    guard let decimal = Int(chunk.hex, radix: 16) else {
                                                        return
                                                    }
                                                    currentToken._decimal = decimal
                                                    
                                                    // 8 : Mint 2 Bytes
                                                    // Good
                                                    chunk = chunks[8].chunkData.removeLeft()
                                                    if let mv = Int(chunk.hex, radix: 16) {
                                                        mintVout = mv
                                                    }
                                                    
                                                    // 9 to .. : initial_token_mint_quantity 8 Bytes
                                                    // Good
                                                    chunk = chunks[9].chunkData.removeLeft()
                                                    if let balance = Int(chunk.hex, radix: 16) {
                                                        voutToTokenQty.append(balance)
                                                    }
                                                    
                                                } else if transactionType == SLPTransactionType.SEND.rawValue {
                                                    
                                                    // 3 : token_id 32 bytes  hex
                                                    // Good
                                                    chunk = chunks[3].chunkData.removeLeft()
                                                    let tokenId = chunk.hex
                                                    currentToken._tokenId = tokenId
                                                    
                                                    // If the token is already found, continue to work on it
                                                    if let token = updatedTokens[tokenId] {
                                                        currentToken = token
                                                    }
                                                    
                                                    // 4 to .. : token_output_quantity 1..19 8 Bytes / qty
                                                    for i in 4...chunks.count - 1 {
                                                        chunk = chunks[i].chunkData.removeLeft()
                                                        if let balance = Int(chunk.hex, radix: 16) {
                                                            voutToTokenQty.append(balance)
                                                        } else {
                                                            break
                                                        }
                                                    }
                                                } else if transactionType == SLPTransactionType.MINT.rawValue {
                                                    
                                                    // 3 : token_id 32 bytes  hex
                                                    // Good
                                                    chunk = chunks[3].chunkData.removeLeft()
                                                    let tokenId = chunk.hex
                                                    currentToken._tokenId = tokenId
                                                    
                                                    // If the token is already found, continue to work on it
                                                    if let token = updatedTokens[tokenId] {
                                                        currentToken = token
                                                    }
                                                    
                                                    // 4 : Mint 2 Bytes
                                                    // Good
                                                    chunk = chunks[4].chunkData.removeLeft()
                                                    if let mv = Int(chunk.hex, radix: 16) {
                                                        mintVout = mv
                                                    }
                                                    
                                                    // 5 : additional_token_quantity 8 Bytes
                                                    // Good
                                                    chunk = chunks[5].chunkData.removeLeft()
                                                    if let balance = Int(chunk.hex, radix: 16) {
                                                        voutToTokenQty.append(balance)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Get the vouts that we are interested in
                                        let vouts = utxos.filter({ return $0.txid == tx.txid })
                                        vouts.forEach({ utxo in
                                            let vout = tx.vout[utxo.vout]
                                            
                                            guard let rawAddress = vout.scriptPubKey.addresses?.first
                                                , let address = try? AddressFactory.create(rawAddress) else {
                                                return
                                            }
                                            
                                            let cashAddress = address.cashaddr
                                            
                                            guard vout.n < voutToTokenQty.count
                                                , voutToTokenQty.count > 1
                                                , voutToTokenQty[vout.n] > 0 else { // Because we push 1 vout qty by default for the OP_RETURN
                                                
                                                // We need to avoid using the mint baton
                                                if vout.n == mintVout && mintVout > 0 {
                                                    // UTXO with baton
                                                    currentToken._mintUTXO = SLPWalletUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n)
                                                } else {
                                                    // UTXO without token
                                                    let utxo = SLPWalletUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n)
                                                    updatedUTXOs.append(utxo)
                                                }
                                                
                                                return
                                            }
                                            
                                            // UTXO with a token
                                            let rawTokenQty = voutToTokenQty[vout.n]
                                            let tokenUTXO = SLPTokenUTXO(tx.txid, satoshis: vout.value.toSatoshis(), cashAddress: cashAddress, scriptPubKey: vout.scriptPubKey.hex, index: vout.n, rawTokenQty: rawTokenQty)
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
                                            if token.utxos.count > 0 {
                                                newTokens.append(token)
                                            }
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
                                            t._utxos = token.utxos
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
                        let value = try SLPTransactionBuilder.build(self, tokenId: tokenId, amount: amount, toAddress: toAddress)
                        RestService
                            .broadcast(value.rawTx)
                            .subscribe({ response in
                                switch response {
                                case.success(let txid):
                                    
                                    guard let token = self.tokens[tokenId] else {
                                        return single(.success(txid))
                                    }
                                    
                                    self.updateUTXOsAfterSending(token, usedUTXOs: value.usedUTXOs, newUTXOs: value.newUTXOs)
                                    
                                    // Update delegate
                                    self.delegate?.onUpdatedToken(token)
                                    
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
                            token._tokenTicker = tokenTicker
                            
                            // 4 : token_name UTF8
                            // Good
                            chunk = chunks[4].chunkData.removeLeft()
                            guard let tokenName = chunk.stringUTF8 else {
                                return
                            }
                            token._tokenName = tokenName
                            
                            // 8 : decimal 1 Byte
                            // Good
                            chunk = chunks[7].chunkData.removeLeft()
                            guard let decimal = Int(chunk.hex, radix: 16) else {
                                return
                            }
                            token._decimal = decimal
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

extension SLPWallet {
    func getPrivKeyByCashAddress(_ cashAddress: String) -> PrivateKey? {
        switch cashAddress {
        case BCHAccount.cashAddress:
            return BCHAccount.privKey
        case SLPAccount.cashAddress:
            return SLPAccount.privKey
        default:
            return nil
        }
    }
    
    func updateUTXOsAfterSending(_ token: SLPToken, usedUTXOs: [SLPWalletUTXO], newUTXOs: [SLPWalletUTXO]) {
        newUTXOs.forEach({ UTXO in
            guard let newUTXO = UTXO as? SLPTokenUTXO else {
                return self.addUTXO(UTXO)
            }
            return token.addUTXO(newUTXO)
        })
        
        usedUTXOs.forEach({ UTXO in
            guard let newUTXO = UTXO as? SLPTokenUTXO else {
                return self.removeUTXO(UTXO)
            }
            return token.removeUTXO(newUTXO)
        })
    }
    
    func addUTXO(_ utxo: SLPWalletUTXO) {
        _utxos.append(utxo)
    }
    
    func removeUTXO(_ utxo: SLPWalletUTXO) {
        guard let i = _utxos.firstIndex(where: { $0.index == utxo.index && $0.txid == utxo.txid }) else {
            return
        }
        _utxos.remove(at: i)
    }
}
