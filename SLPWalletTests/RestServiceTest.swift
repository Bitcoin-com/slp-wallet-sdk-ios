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
                }
            }
        }
    }
}
