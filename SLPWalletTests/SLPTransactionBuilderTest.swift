//
//  SLPTransactionBuilderTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class SLPTransactionBuilderTest: QuickSpec {
    override func spec() {
        describe("SLPTransactionBuilder") {
            context("Build a transaction") {
                
                it("should fail TOKEN_NOT_FOUND") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    do {
                        _ = try SLPTransactionBuilder.build(wallet, tokenId: "test", amount: 12, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        fail()
                    } catch SLPTransactionBuilderError.TOKEN_NOT_FOUND {
                        // Success
                    } catch {
                        fail()
                    }
                }
                
                it("should fail DECIMAL_NOT_AVAILABLE") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06")
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qz43q5tu8m6kwc20lxe5jvmrrlx9jcsdcuh5hvh23l", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        _ = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 12, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        fail()
                    } catch SLPTransactionBuilderError.DECIMAL_NOT_AVAILABLE {
                        // Success
                    } catch {
                        fail()
                    }
                }
                
                it("should fail INSUFFICIENT_FUNDS") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06")
                    token.decimal = 0
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qz43q5tu8m6kwc20lxe5jvmrrlx9jcsdcuh5hvh23l", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        _ = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 1235, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        fail()
                    } catch SLPTransactionBuilderError.INSUFFICIENT_FUNDS {
                        // Success
                    } catch {
                        fail()
                    }
                }
                
                it("should fail CONVERSION_METADATA") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("test")
                    token.decimal = 0
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qz43q5tu8m6kwc20lxe5jvmrrlx9jcsdcuh5hvh23l", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["test"] = token
                    
                    do {
                        _ = try SLPTransactionBuilder.build(wallet, tokenId: "test", amount: 1234, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        fail()
                    } catch SLPTransactionBuilderError.CONVERSION_METADATA {
                        // Success
                    } catch {
                        fail()
                    }
                }
                
                it("should fail GAS_INSUFFISANT") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06")
                    token.decimal = 2
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qz43q5tu8m6kwc20lxe5jvmrrlx9jcsdcuh5hvh23l", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        _ = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 12, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        fail()
                    } catch SLPTransactionBuilderError.GAS_INSUFFICIENT {
                        // Success
                    } catch {
                        fail()
                    }
                }
                
                it("should success") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06")
                    token.decimal = 2
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 20000, cashAddress: "bitcoincash:qz43q5tu8m6kwc20lxe5jvmrrlx9jcsdcuh5hvh23l", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        let rawTx = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 12, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        expect(rawTx).to(equal("0100000001060f095464b748f3d383b677f0cd5c85807d4b2324412e2759b64706a72f42e3010000006b483045022100c22fb8802b7d539e8143a8b6f71cf4c0d1b496a5846d5f480277bd4360032f8b02204508d9304f5b62d0e29b07a13234cff2f5c1adc54fb34cc2d7207556127e184e41210329d5ffda1250d97614cfd3a5cb1c89d0a255c59584c091915b21b3e64137fe7affffffff040000000000000000406a04534c500001010453454e4420e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f060800000000000004b008000000000000002222020000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac22020000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac85470000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac00000000"))
                    } catch {
                        fail()
                    }
                }
            }
        }
    }
}

