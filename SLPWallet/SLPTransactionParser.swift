//
//  SLPTransactionParser.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/01.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPTransactionParser {
//    func parse(script: Script) -> SLPTransaction? {
//        var chunks = script.scriptChunks
//        
//        guard chunks.removeFirst().opCode == .OP_RETURN else {
//            return nil
//        }
//        
//        // 2 : transaction_type 4 bytes ASCII
//        // Good
//        var chunk = chunks[2].chunkData.clean()
//        guard let transactionType = String(data: chunk, encoding: String.Encoding.ascii) else {
//            return nil
//        }
//        
//        if transactionType == SLPTransactionType.GENESIS.rawValue {
//            
//            // 3 : token_ticker UTF8
//            // Good
//            chunk = chunks[3].chunkData.clean()
//            guard let tokenTicker = String(data: chunk, encoding: String.Encoding.utf8) else {
//                return nil
//            }
//            
//            // 4 : token_name UTF8
//            // Good
//            chunk = chunks[4].chunkData.clean()
//            guard let tokenName = String(data: chunk, encoding: String.Encoding.utf8) else {
//                return nil
//            }
//            
//            // 8 : decimal 1 Byte
//            // Good
//            chunk = chunks[7].chunkData.clean()
//            guard let decimal = Int(chunk.hex, radix: 16) else {
//                return nil
//            }
//            
//            return SLPTransaction(tokenId: nil, tokenTicker: tokenTicker, tokenName: tokenName, type: SLPTransactionType.GENESIS, decimal: decimal, tokens: nil)
//        } else {
//            
//        }
//        
//    }
}
