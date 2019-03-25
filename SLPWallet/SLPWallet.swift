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
                        
                        let observeTxDetails = Observable
                            .zip(requests
                                .map { RestService
                                    .fetchTxDetails($0)
                                    .asObservable() })
                        
                        
                        let observeTxValidations = Observable
                            .zip(requests
                                .map { RestService
                                    .fetchTxValidations($0)
                                    .asObservable() })
                            
                        Observable
                            .combineLatest(observeTxDetails, observeTxValidations)
                            .subscribe({ event in
                                switch event {
                                case .next(let response):
                                    
                                    let txs = response.0.flatMap({ $0 })
                                    
                                    // Set hashmap by txid
                                    var txValidations =  [String: Bool]()
                                    
                                    response.1
                                        .flatMap({ $0 })
                                        .forEach { txValidations[$0.txid] = $0.valid }
                                    
                                    var updatedTokens = [String:SLPToken]()
                                    var updatedUTXOs = [SLPWalletUTXO]()
                                    
                                    txs.forEach({ tx in
                                        
                                        // Get the vouts that we are interested in
                                        let vouts = utxos
                                            .filter { $0.txid == tx.txid }
                                            .map { $0.vout }
                                        
                                        // Parse tx
                                        guard let parsedData = SLPTransactionParser.parse(tx, vouts: vouts) else {
                                            return
                                        }
                                        
                                        if let tokenId = parsedData.token.tokenId {
                                            
                                            // Validate the utxos if it should be
                                            parsedData.token._utxos.forEach { $0._isValid = txValidations[$0.txid] ?? false }
                                            
                                            if let token = updatedTokens[tokenId] {
                                                token.merge(parsedData.token)
                                            } else {
                                                updatedTokens[tokenId] = parsedData.token
                                            }
                                        }
                                        
                                        updatedUTXOs.append(contentsOf: parsedData.utxos)
                                    })
                                    
                                    //
                                    //
                                    // Parse finished
                                    // Update data
                                    //
                                    //
                                    
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
                                    
                                    //
                                    //
                                    // Update data finished
                                    // Get info on unknown tokens
                                    //
                                    //
                                    
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
