//
//  SLPTokenUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPTokenUTXO: SLPUTXO {
    public var rawTokenQty: Int
    public var tokenQty: Double?
    
    public init(_ txid: String, satoshis: Int, cashAddress: String, scriptPubKey: String, index: Int, rawTokenQty: Int) {
        self.rawTokenQty = rawTokenQty
        super.init(txid, satoshis: satoshis, cashAddress: cashAddress, scriptPubKey: scriptPubKey, index: index)
    }
}
