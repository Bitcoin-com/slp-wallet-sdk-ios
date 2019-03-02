//
//  SLPToken.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPToken {
    public var tokenId: String?
    public var tokenTicker: String?
    public var tokenName: String?
    public var utxos = [SLPTokenUTXO]()
    public var decimal: Int? {
        willSet {
            guard let newValue = newValue else {
                return
            }
            // If decimal == 0, replace per the rawTokenQty
            utxos.forEach { $0.tokenQty = (newValue > 0 ? (Double($0.rawTokenQty) / pow(Double(10), Double(newValue))) : Double($0.rawTokenQty)) }
        }
    }
    
    public init() {
    }
    
    public init(_ tokenId: String) {
        self.tokenId = tokenId
    }
    
    public func getGas() -> Int {
        return utxos.reduce(0, { $0 + $1.satoshis })
    }
    
    public func getBalance() -> Double {
        return utxos.reduce(0, { $0 + ($1.tokenQty ?? 0) })
    }
}
