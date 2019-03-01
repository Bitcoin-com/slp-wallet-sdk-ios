//
//  Entities.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPUTXO {
    public var txid: String
    public var satoshis: Int
    public var cashAddress: String
    public var scriptPubKey: String
    public var index: Int
    
    public init(_ txid: String, satoshis: Int, cashAddress: String, scriptPubKey: String, index: Int) {
        self.txid = txid
        self.satoshis = satoshis
        self.cashAddress = cashAddress
        self.scriptPubKey = scriptPubKey
        self.index = index
    }
}

public class TokenUTXO: SLPUTXO {
    public var rawTokenQty: Int
    public var tokenQty: Float?
    
    public init(_ txid: String, satoshis: Int, cashAddress: String, scriptPubKey: String, index: Int, rawTokenQty: Int) {
        self.rawTokenQty = rawTokenQty
        super.init(txid, satoshis: satoshis, cashAddress: cashAddress, scriptPubKey: scriptPubKey, index: index)
    }
}

public class SLPToken {
    public var tokenId: String?
    public var tokenTicker: String?
    public var tokenName: String?
    public var utxos = [TokenUTXO]()
    public var decimal: Int? {
        willSet {
            guard let newValue = newValue else {
                return
            }
            // If decimal == 0, replace per the rawTokenQty
            utxos.forEach { $0.tokenQty = (newValue > 0 ? (Float($0.rawTokenQty) / pow(Float(10), Float(newValue))) : Float($0.rawTokenQty)) }
        }
    }
    
    public init() {
    }
    
    public func getGas() -> Int {
        return utxos.reduce(0, { $0 + $1.satoshis })
    }
    
    public func getBalance() -> Float {
        return utxos.reduce(0, { $0 + ($1.tokenQty ?? 0) })
    }
}
