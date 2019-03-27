//
//  SLPToken.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import RxSwift

public class SLPToken {
    var _tokenId: String?
    var _tokenTicker: String?
    var _tokenName: String?
    var _mintUTXO: SLPWalletUTXO?
    var _decimal: Int? {
        willSet {
            guard let decimal = newValue else {
                return
            }
            
            // If decimal == 0, replace per the rawTokenQty
            _utxos.forEach { $0._tokenQty = (decimal > 0 ? (Double($0._rawTokenQty) / pow(Double(10), Double(decimal))) : Double($0.rawTokenQty)) }
        }
    }
    
    var _utxos = [SLPTokenUTXO]() {
        willSet {
            guard let decimal = self.decimal else {
                return
            }
            
            // If decimal == 0, replace per the rawTokenQty
            newValue.forEach { $0._tokenQty = (decimal > 0 ? (Double($0._rawTokenQty) / pow(Double(10), Double(decimal))) : Double($0._rawTokenQty)) }
        }
    }
    
    // Public interface
    public var tokenId: String? { get { return _tokenId } }
    public var tokenTicker: String? { get { return _tokenTicker } }
    public var tokenName: String? { get { return _tokenName } }
    public var mintUTXO: SLPWalletUTXO? { get { return _mintUTXO } }
    public var decimal: Int? { get { return _decimal } }
    public var utxos: [SLPTokenUTXO] { get { return _utxos.filter { $0.isValid } } }
    
    public init() {
    }
    
    public init(_ tokenId: String) {
        self._tokenId = tokenId
    }
    
    public func getGas() -> Int {
        return utxos.reduce(0, { $0 + Int($1.satoshis) })
    }
    
    public func getBalance() -> Double {
        return utxos.reduce(0, { $0 + ($1.tokenQty ?? 0) })
    }
}
    
extension SLPToken {
    func addUTXO(_ utxo: SLPTokenUTXO) {
        guard let decimal = self.decimal else {
            _utxos.append(utxo)
            return
        }
        
        utxo._tokenQty = decimal > 0 ? (Double(utxo.rawTokenQty) / pow(Double(10), Double(decimal))) : Double(utxo.rawTokenQty)
        _utxos.append(utxo)
    }
    
    func addUTXOs(_ utxos: [SLPTokenUTXO]) {
        utxos.forEach({ self.addUTXO($0) })
    }
    
    func removeUTXO(_ utxo: SLPTokenUTXO) {
        guard let i = _utxos.firstIndex(where: { $0.index == utxo.index && $0.txid == utxo.txid }) else {
            return
        }
        _utxos.remove(at: i)
    }
    
    func merge(_ token: SLPToken) -> SLPToken {
        if let tokenId = token._tokenId {
            self._tokenId = tokenId
        }
        if let tokenName = token._tokenName {
            self._tokenName = tokenName
        }
        if let tokenTicker = token._tokenTicker {
            self._tokenTicker = tokenTicker
        }
        if let decimal = token._decimal {
            self._decimal = decimal
        }
        if let mintUTXO = token._mintUTXO {
            self._mintUTXO = mintUTXO
        }
        self._utxos.append(contentsOf: token._utxos)
        
        return self
    }
}
