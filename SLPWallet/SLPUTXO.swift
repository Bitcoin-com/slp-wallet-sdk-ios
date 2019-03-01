//
//  SLPUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
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
