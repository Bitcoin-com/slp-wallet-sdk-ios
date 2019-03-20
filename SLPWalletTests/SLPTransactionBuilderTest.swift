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
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
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
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
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
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1000, cashAddress: "bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
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
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 1500, cashAddress: "bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        _ = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 11, toAddress: "simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny")
                        fail()
                    } catch SLPTransactionBuilderError.GAS_INSUFFICIENT {
                        // Success
                    } catch (let error){
                        fail()
                    }
                }
                
                it("should success") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06")
                    token.decimal = 2
                                        
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 20000, cashAddress: "bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        let rawTx = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 12, toAddress: "simpleledger:qqs5mxuxr9kaukncpgdc7z64zp6t87rk7cwtkvhpjv")
                        
                         expect(rawTx).to(equal("0100000001060f095464b748f3d383b677f0cd5c85807d4b2324412e2759b64706a72f42e3010000006b483045022100c61043958930339cd775eee7c90c66bbc32b7204f9bd47b00e36b205cf03a73b022055e8432873b0e5aa8d1de917db30fe8970318bfcb528a758f69476d98bf3e8c341210329d5ffda1250d97614cfd3a5cb1c89d0a255c59584c091915b21b3e64137fe7affffffff040000000000000000406a04534c500001010453454e4420e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f060800000000000004b008000000000000002222020000000000001976a914214d9b86196dde5a780a1b8f0b551074b3f876f688ac22020000000000001976a914ac554d6f334d82809124a91b947271db67c0b80088ac85470000000000001976a9149b4858ef89806fef10d112e585c2cc01ea429b2e88ac00000000"))
                    } catch {
                        fail()
                    }
                }
            }
        }
    }
}

