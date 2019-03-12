//
//  SLPTransactionParser.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/01.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import BitcoinKit

// TODO: Move all the parsering here to clean SLPWallet
//
enum SLPTransactionType: String {
    case GENESIS
    case SEND
}

//class SLPTransaction {
//    var tokenId: String?
//    var tokenTicker: String?
//    var tokenName: String?
//    var decimal: Int?
//    var voutToTokenQty: [Int]?
//
//    init() {}
//}

// TODO: Finish the parse
//public class SLPTransactionParser {
//    static func parse(tx: RestService.ResponseTx) throws -> SLPTransaction? {
//        let SLPTx = SLPTransaction()
//
//        let script = Script(hex: tx.vout[0].scriptPubKey.hex)
//
//        var voutToTokenQty = [Int]()
//        voutToTokenQty.append(0) // To have the same mapping with the vouts
//
//        if var chunks = script?.scriptChunks
//            , chunks.removeFirst().opCode == .OP_RETURN {
//
//            // 0 : lokad id 4 bytes ASCII
//            // Good
//            guard let lokadId = chunks[0].chunkData.removeLeft().removeRight().stringASCII else {
//                return nil
//            }
//
//            if lokadId == "SLP" {
//
//                // 1 : token_type 1 bytes Integer
//                // Good
//                var chunk = chunks[1].chunkData.removeLeft()
//                let tokenType = chunk.uint8
//
//                // 2 : transaction_type 4 bytes ASCII
//                // Good
//                chunk = chunks[2].chunkData.removeLeft()
//                guard let transactionType = chunks[2].chunkData.removeLeft().stringASCII else {
//                    return nil
//                }
//
//                if transactionType == SLPTransactionType.GENESIS.rawValue {
//
//                    // Genesis => Txid
//                    let tokenId = tx.txid
//                    SLPTx.tokenId = tokenId
//
//                    // 3 : token_ticker UTF8
//                    // Good
//                    chunk = chunks[3].chunkData.removeLeft()
//                    guard let tokenTicker = chunk.stringUTF8 else {
//                        return nil
//                    }
//                    SLPTx.tokenTicker = tokenTicker
//
//                    // 4 : token_name UTF8
//                    // Good
//                    chunk = chunks[4].chunkData.removeLeft()
//                    guard let tokenName = chunk.stringUTF8 else {
//                        return nil
//                    }
//                    SLPTx.tokenName = tokenName
//
//                    // 8 : decimal 1 Byte
//                    // Good
//                    chunk = chunks[7].chunkData.removeLeft()
//                    guard let decimal = Int(chunk.hex, radix: 16) else {
//                        return nil
//                    }
//                    SLPTx.decimal = decimal
//
//                    // 3 : token_id 32 bytes  hex
//                    // Good
//                    chunk = chunks[9].chunkData.removeLeft()
//                    guard let balance = Int(chunk.hex, radix: 16) else {
//                        return nil
//                    }
//                    voutToTokenQty.append(balance)
//
//                } else if transactionType == SLPTransactionType.SEND.rawValue {
//
//                    // 3 : token_id 32 bytes  hex
//                    // Good
//                    chunk = chunks[3].chunkData.removeLeft()
//                    let tokenId = chunk.hex
//                    SLPTx.tokenId = tokenId
//
//                    // 4 to .. : token_output_quantity 1..19
//                    for i in 4...chunks.count - 1 {
//                        chunk = chunks[i].chunkData.removeLeft()
//                        if let balance = Int(chunk.hex, radix: 16) {
//                            voutToTokenQty.append(balance)
//                        } else {
//                            break
//                        }
//                    }
//                }
//            }
//        }
//
//        return SLPTx
//    }
//}
