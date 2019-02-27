//
//  StoreUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

struct StoreUTXO {
    let id: String // txid-vout
    let txid: String
    let vout: Int
    let satoshis: Int
    let confirmations: Int
    let scriptPubKey: String
    
//    func asUnspentTransaction() -> UnspentTransaction {
//        let transactionOutput = TransactionOutput(value: Int64(satoshis), lockingScript: Data(hex: scriptPubKey)!)
//        let txid: Data = Data(hex: String(self.txid))!
//        let txHash: Data = Data(txid.reversed())
//        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: UInt32(vout))
//        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
//    }
}
