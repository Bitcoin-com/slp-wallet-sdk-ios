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
            
            beforeEach {
                SLPWalletConfig.setRestURL("https://rest.bitcoin.com/v2")
            }
            
            context("Fetch UTXO") {
                it("should success") {
                    let utxos = try! RestService
                        .fetchUTXOs(["bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6"])
                        .toBlocking()
                        .single()
                    expect(utxos).notTo(beNil())
                    expect(utxos.first?.scriptPubKey).to(equal("76a914ac554d6f334d82809124a91b947271db67c0b80088ac"))
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
            
            context("Broadcast RawTx") {
                it("should fail") {
                    do {
                        _ = try RestService
                            .broadcast("0100000001060f095464b748f3d383b677f0cd5c85807d4b2324412e2759b64706a72f42e3010000006b483045022100c22fb8802b7d539e8143a8b6f71cf4c0d1b496a5846d5f480277bd4360032f8b02204508d9304f5b62d0e29b07a13234cff2f5c1adc54fb34cc2d7207556127e184e41210329d5ffda1250d97614cfd3a5cb1c89d0a255c59584c091915b21b3e64137fe7affffffff040000000000000000406a04534c500001010453454e4420e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f060800000000000004b008000000000000002222020000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac22020000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac85470000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac00000000")
                            .toBlocking()
                            .single()
                        fail()
                    } catch RestService.RestError.REST_SEND_RAW_TX {
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
                        let txValidations = try RestService
                            .fetchTxValidations(["test"])
                            .toBlocking()
                            .single()
                        fail()
                    } catch {
                        // success
                    }
                }
            }
        }
    }
}
