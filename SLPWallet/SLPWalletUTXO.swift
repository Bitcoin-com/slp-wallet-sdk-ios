//
//  SLPUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import BitcoinKit

public class SLPWalletUTXO {
    fileprivate var _txid: String
    fileprivate var _satoshis: Int
    fileprivate var _cashAddress: String
    fileprivate var _scriptPubKey: String
    fileprivate var _index: Int
    
    public var txid: String { get { return _txid } }
    public var satoshis: Int { get { return _satoshis } }
    public var cashAddress: String { get { return _cashAddress } }
    public var scriptPubKey: String { get { return _scriptPubKey } }
    public var index: Int { get { return _index } }
    
//    TODO: Activate for storage (Codable)
//    private enum CodingKeys: String, CodingKey {
//        case _txid
//        case _satoshis
//        case _cashAddress
//        case _scriptPubKey
//        case _index
//    }
//
//    required public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self._txid = try container.decode(String.self, forKey: ._txid)
//        self._satoshis = try container.decode(Int.self, forKey: ._satoshis)
//        self._cashAddress = try container.decode(String.self, forKey: ._cashAddress)
//        self._scriptPubKey = try container.decode(String.self, forKey: ._scriptPubKey)
//        self._index = try container.decode(Int.self, forKey: ._index)
//    }
    
    public init(_ txid: String, satoshis: Int, cashAddress: String, scriptPubKey: String, index: Int) {
        self._txid = txid
        self._satoshis = satoshis
        self._cashAddress = cashAddress
        self._scriptPubKey = scriptPubKey
        self._index = index
    }
    
    func asUnspentTransaction() -> UnspentTransaction {
        let transactionOutput = TransactionOutput(value: UInt64(_satoshis), lockingScript: Data(hex: _scriptPubKey)!)
        let txid: Data = Data(hex: String(_txid))!
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: UInt32(_index))
        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
    }
}