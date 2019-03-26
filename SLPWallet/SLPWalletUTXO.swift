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
    var _txid: String // TODO: Expose until I fix the TransactionBuilder to provide the right tx directly
    fileprivate var _satoshis: Int64
    fileprivate var _cashAddress: String
    fileprivate var _scriptPubKey: String
    fileprivate var _index: Int
    
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
    
    public var txid: String { get { return _txid } }
    public var satoshis: Int64 { get { return _satoshis } }
    public var cashAddress: String { get { return _cashAddress } }
    public var scriptPubKey: String { get { return _scriptPubKey } }
    public var index: Int { get { return _index } }
    
    public init(_ txid: String, satoshis: Int64, cashAddress: String, scriptPubKey: String, index: Int) {
        self._txid = txid
        self._satoshis = satoshis
        self._cashAddress = cashAddress
        self._scriptPubKey = scriptPubKey
        self._index = index
    }
}

extension SLPWalletUTXO {
    func asUnspentTransaction() -> UnspentTransaction {
        let transactionOutput = TransactionOutput(value: UInt64(_satoshis), lockingScript: Data(hex: _scriptPubKey)!)
        let txid: Data = Data(hex: String(_txid))!
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: UInt32(_index))
        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
    }
}

extension SLPWalletUTXO: Equatable {
    public static func == (lhs: SLPWalletUTXO, rhs: SLPWalletUTXO) -> Bool {
        return lhs.index == rhs.index &&
            lhs.txid == rhs.txid
    }
}

extension SLPWalletUTXO: Hashable {
    public var hashValue: Int {
        return txid.hashValue << 8 | index
    }
}
