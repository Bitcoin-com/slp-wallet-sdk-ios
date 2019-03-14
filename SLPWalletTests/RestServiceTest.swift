//
//  RestServiceTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
import RxBlocking
@testable import SLPWallet

class RestServiceTest: QuickSpec {
    override func spec() {
        describe("RestService") {
            
            context("Fetch UTXO") {
                it("should success") {
                    let utxos = try! RestService
                        .fetchUTXOs("bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6")
                        .toBlocking()
                        .single()
                    expect(utxos).notTo(beNil())
                    expect(utxos.scriptPubKey).to(equal("76a914ac554d6f334d82809124a91b947271db67c0b80088ac"))
                }
            }
            
            context("Fetch TxDetails") {
                it("should success") {
                    let txs = try! RestService
                        .fetchTxDetails(["ce7f87ac5d086ad1c736c472ce5bc75f020bf22d3e2ed8603c675a6517b9c1cd"])
                        .toBlocking()
                        .single()
                    expect(txs).notTo(beNil())
                }
                
                it("should fail") {
                    do {
                        _ = try RestService
                            .fetchTxDetails(["test"])
                            .toBlocking()
                            .single()
                        fail()
                    } catch RestService.RestError.REST_TX_DETAILS {
                        // Success
                    } catch {
                        fail()
                    }
                }
            }
            
            context("Fetch TxDetails") {
                it("should success + valid") {
                    let txValidations = try! RestService
                        .fetchTxValidations(["7657b6eb3dbd13ceb0c02a027a44118ede354768689aebd8ebf7007e5a21ae42"])
                        .toBlocking()
                        .single()
                    expect(txValidations).notTo(beNil())
                    expect(txValidations.count).to(equal(1))
                    expect(txValidations.first?.txid).to(equal("7657b6eb3dbd13ceb0c02a027a44118ede354768689aebd8ebf7007e5a21ae42"))
                    expect(txValidations.first?.valid).to(equal(true))
                }
                
                it("should success + invalid") {
                    let txValidations = try! RestService
                        .fetchTxValidations(["b42876f55585019f588a39d24a664f8d93fba224e65eef2c1c1979f14069d102"])
                        .toBlocking()
                        .single()
                    expect(txValidations).notTo(beNil())
                    expect(txValidations.count).to(equal(1))
                    expect(txValidations.first?.txid).to(equal("b42876f55585019f588a39d24a664f8d93fba224e65eef2c1c1979f14069d102"))
                    expect(txValidations.first?.valid).to(equal(false))
                }
                
                it("should fail") {
                    do {
                        _ = try RestService
                            .fetchTxValidations(["test"])
                            .toBlocking()
                            .single()
                        fail()
                    } catch RestService.RestError.REST_TX_VALIDATIONS {
                        // Success
                    } catch {
                        fail()
                    }
                }
            }
        }
    }
}
