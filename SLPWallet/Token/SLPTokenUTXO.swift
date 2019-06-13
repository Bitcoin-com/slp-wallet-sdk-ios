//
//  SLPTokenUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPTokenUTXO: SLPWalletUTXO {
    var _rawTokenQty: Int
    var _tokenQty: Double?
    var _isValid: Bool
    
    public var rawTokenQty: Int { get { return _rawTokenQty } }
    public var tokenQty: Double? { get { return _tokenQty } }
    public var isValid: Bool { get { return _isValid } }
    
    public init(_ txid: String, satoshis: Int64, cashAddress: String, scriptPubKey: String, index: Int, rawTokenQty: Int) {
        self._rawTokenQty = rawTokenQty
        self._isValid = false
        super.init(txid, satoshis: satoshis, cashAddress: cashAddress, scriptPubKey: scriptPubKey, index: index)
    }
}
