//
//  SLPWalletUTXOTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class SLPWalletUTXOTest: QuickSpec {
    override func spec() {
        describe("SLPWalletUTXO") {
            context("Create SLPWalletUTXO") {
                it("should success") {
                    let utxo = SLPWalletUTXO("txid", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1)
                    expect(utxo.txid).to(equal("txid"))
                    expect(utxo.satoshis).to(equal(100))
                    expect(utxo.cashAddress).to(equal("cashAddress"))
                    expect(utxo.scriptPubKey).to(equal("scriptPubKey"))
                    expect(utxo.index).to(equal(1))
                }
            }
            context("Equal SLPWalletUTXO") {
                it("should be equal") {
                    let utxo1 = SLPWalletUTXO("txid1", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1)
                    let utxo2 = SLPWalletUTXO("txid1", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1)
                    expect(utxo1 == utxo2).to(equal(true))
                }
                
                it("should be not equal") {
                    let utxo1 = SLPWalletUTXO("txid1", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1)
                    let utxo2 = SLPWalletUTXO("txid2", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1)
                    expect(utxo1 == utxo2).to(equal(false))
                }
                
                it("should be not equal") {
                    let utxo1 = SLPWalletUTXO("txid1", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 1)
                    let utxo2 = SLPWalletUTXO("txid1", satoshis: 100, cashAddress: "cashAddress", scriptPubKey: "scriptPubKey", index: 2)
                    expect(utxo1 == utxo2).to(equal(false))
                }
            }
        }
    }
}
