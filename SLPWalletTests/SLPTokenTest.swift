//
//  SLPTokenTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class SLPWalletTokenTest: QuickSpec {
    override func spec() {
        describe("SLPWalletToken") {
            context("Add UTXOs") {
                it("should success") {
                    let token = SLPToken("test")
                    
                    let utxo = SLPTokenUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1, rawTokenQty: 10)
                    token.addUTXOs([utxo])
                    
                    expect(token._utxos.count).to(equal(1))
                }
            }
            
            context("Add UTXO") {
                it("should success") {
                    let token = SLPToken("test")
                    
                    let utxo = SLPTokenUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1, rawTokenQty: 10)
                    token.addUTXO(utxo)
                    
                    expect(token._utxos.count).to(equal(1))
                }
            }
            
            context("Get balance without decimal") {
                it("should success") {
                    let token = SLPToken("test")
                    
                    let utxo = SLPTokenUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1, rawTokenQty: 10)
                    utxo._isValid = true
                    
                    token.addUTXO(utxo)
                    
                    expect(token.getBalance()).to(equal(0))
                }
            }
            
            context("Get balance with decimal nil") {
                it("should success") {
                    let token = SLPToken("test")
                    token._decimal = nil
                    
                    let utxo = SLPTokenUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1, rawTokenQty: 10)
                    utxo._isValid = true
                    
                    token.addUTXO(utxo)
                    
                    expect(token.getBalance()).to(equal(0))
                }
            }
            
            context("Get balance with decimal 2") {
                it("should success") {
                    let token = SLPToken("test")
                    token._decimal = 2
                    
                    let utxo = SLPTokenUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1, rawTokenQty: 10)
                    utxo._isValid = true
                    
                    token.addUTXO(utxo)
                    
                    expect(token.getBalance()).to(equal(0.1))
                }
            }
            
            context("Get balance with decimal 0") {
                it("should success") {
                    let token = SLPToken("test")
                    token._decimal = 0
                    
                    let utxo = SLPTokenUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1, rawTokenQty: 10)
                    utxo._isValid = true
                    
                    token.addUTXO(utxo)
                    
                    expect(token.getBalance()).to(equal(10))
                }
            }
        }
    }
}
