//
//  SLPTokenUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPTokenUTXO: SLPUTXO {
    var _rawTokenQty: Int
    var _tokenQty: Double?
    
    public var rawTokenQty: Int { get { return _rawTokenQty } }
    public var tokenQty: Double? { get { return _tokenQty } }
    
    public init(_ txid: String, satoshis: Int, cashAddress: String, scriptPubKey: String, index: Int, rawTokenQty: Int) {
        self._rawTokenQty = rawTokenQty
        super.init(txid, satoshis: satoshis, cashAddress: cashAddress, scriptPubKey: scriptPubKey, index: index)
    }
}
