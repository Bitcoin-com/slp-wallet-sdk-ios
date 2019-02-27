//
//  RestServiceTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import SLPWallet
import Nimble
import Quick
import RxBlocking
import BitcoinKit

class RestServiceTest: QuickSpec {
    override func spec() {
        describe("RestService") {
            describe("Fetch UTXO") {
                it("success with 1 address") {
                    let utxos = try! RestService
                        .fetchUTXOs("bitcoincash:qrkn34tllug35tfs655e649asx4udw4dccaygv6wcr")
                        .toBlocking()
                        .single()
                    
                    expect(utxos).notTo(beNil())
                    expect(utxos.scriptPubKey).to(equal("76a914ed38d57fff111a2d30d5299d54bd81abc6baadc688ac"))
                    expect(utxos.utxos).to(haveCount(1))
                }
            }
            
            describe("Fetch TxDetails") {
                it("success with 1 txid") {
                    let txs = try! RestService
                        .fetchTxDetails("52126b7cb58da053a88ddafacdb6fb97223c0661331a5099a1a04153aace265f")
                        .toBlocking()
                        .single()
                    
                    expect(txs).notTo(beNil())
                    expect(txs[0].vout).to(haveCount(4))
                    
                    txs.forEach({ tx in
                        let script = Script(hex: tx.vout[0].scriptPubKey.hex)

                        guard var chunks = script?.scriptChunks
                            , chunks.removeFirst().opCode == .OP_RETURN else {
                            return
                        }
                        
                        // 0 : lokad id 4 bytes ASCII
                        guard let lokadId = String(data: chunks[0].chunkData, encoding: String.Encoding.ascii) else {
                            return
                        }
                        print("lokadId: \(lokadId)")
                        
                        // 1 : token_type 1 bytes Integer
                        let tokenType = chunks[1].chunkData.uint8
                        print("tokenType: \(tokenType)")
                        
                        // 2 : transaction_type 4 bytes ASCII
                        guard let transactionType = String(data: chunks[2].chunkData, encoding: String.Encoding.ascii) else {
                            return
                        }
                        print("transactionType: \(transactionType)")
                        
                        // 3 : token_id 32 bytes  hex
                        let tokenId = chunks[3].chunkData.hex
                        print("tokenId: \(tokenId)")
                        
                        // 4 : token_output_quantity
                        let tokenOutputQuantity = chunks[4].chunkData.uint8
                        print("tokenOutputQuantity: \(tokenOutputQuantity)")
                    })
                }
            }
        }
    }
}
