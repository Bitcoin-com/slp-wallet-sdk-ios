//
//  SLPWalletTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/02/28.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
import RxBlocking
@testable import SLPWallet

class SLPWalletTest: QuickSpec {
    override func spec() {
        
        describe("SLPWallet") {
            
            beforeEach {
                SLPWalletConfig.setRestURL("https://rest.bitcoin.com/v2")
            }
            
            context("Create wallet") {
                it("should success") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    expect(wallet.mnemonic).to(equal(["machine", "cannon", "man", "rail", "best", "deliver", "draw", "course", "time", "tape", "violin", "tone"]))
                    expect(wallet.cashAddress).to(equal("bitcoincash:qzd5sk803xqxlmcs6yfwtpwzesq75s5m9c3x6gjl8n"))
                    expect(wallet.slpAddress).to(equal("simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny"))
                    expect(wallet.tokens.values.count).to(equal(0))
                    expect(wallet.getGas()).to(equal(0))
                    expect(wallet.getPrivKeyByCashAddress("bitcoincash:qzd5sk803xqxlmcs6yfwtpwzesq75s5m9c3x6gjl8n")).toNot(beNil())
                    expect(wallet.getPrivKeyByCashAddress("bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6")).toNot(beNil())
                    expect(wallet.getPrivKeyByCashAddress("test")).to(beNil())
                    
                    wallet.scheduler.resume()
                    wallet.schedulerInterval = 1
                    
                    expect(wallet.schedulerInterval).to(equal(1))
                }
            }
            
            context("Fetch tokens") {
                it("should success") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    var tokens = try! wallet
                        .fetchTokens()
                        .toBlocking()
                        .single()
                    
                    tokens.forEach({ tokenId, token in
                        expect(token.tokenId).toNot(beNil())
                        expect(token.tokenTicker).toNot(beNil())
                        expect(token.tokenName).toNot(beNil())
                        expect(token.decimal).toNot(beNil())
                        expect(token.getBalance()).toNot(beNil())
                        expect(token.getGas()).toNot(beNil())
                    })
                    
                    // Fetch a second time to parse utxos
                    try! wallet
                        .fetchTokens()
                        .toBlocking()
                        .single()
                }
            }
            
            context("Add token") {
                it("should success") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    let token = SLPToken("ce7f87ac5d086ad1c736c472ce5bc75f020bf22d3e2ed8603c675a6517b9c1cd")
                    let newToken = try! wallet
                        .addToken(token)
                        .toBlocking()
                        .single()
                    
                    expect(newToken.tokenTicker).to(equal("BCC"))
                    expect(newToken.tokenName).to(equal("Bitcoin.com Coin"))
                    expect(newToken.decimal).to(equal(2))
                    expect(newToken.getBalance()).toNot(beNil())
                    expect(newToken.getGas()).toNot(beNil())
                }
            }
            
            context("Secure storage") {
                it("should success") {
                    let createdWallet = try! SLPWallet(.mainnet, force: true)
                    let restoredWallet = try! SLPWallet(.mainnet)
                    expect(restoredWallet.cashAddress).to(equal(createdWallet.cashAddress))
                    expect(restoredWallet.slpAddress).to(equal(createdWallet.slpAddress))
                }
            }
                    
            context("Send token") {
                it("should success") {
                    let wallet = try! SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                    
                    let token = SLPToken("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06")
                    token._decimal = 2
                    
                    let utxo = SLPTokenUTXO("e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", satoshis: 20000, cashAddress: "bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6", scriptPubKey: "483045022100e36b594680823bcf7f4a872611cb7652032e92793f2eadae9ad87a57e4854e3602203ffb057332f47bf9f68738f668acad8ae1d2d3265c34e75c9158c9e9be2ae1f0412103b8ac3da9a09a58444291ce21c68a6b279fe33d3e46a879a4c1ed64bd87146506", index: 1, rawTokenQty: 1234)
                    utxo._isValid = true
                    
                    token.addUTXO(utxo)
                    
                    wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"] = token
                    
                    do {
                        let value = try SLPTransactionBuilder.build(wallet, tokenId: "e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06", amount: 12, toAddress: "simpleledger:qqs5mxuxr9kaukncpgdc7z64zp6t87rk7cwtkvhpjv")
                        
                        wallet.updateUTXOsAfterSending(token, usedUTXOs: value.usedUTXOs, newUTXOs: value.newUTXOs)
                        expect(wallet.getGas()).to(be(18385))
                        expect(wallet._tokens["e3422fa70647b659272e4124234b7d80855ccdf077b683d3f348b76454090f06"]?.getBalance()).to(equal(0.34))
                    } catch {
                        fail()
                    }
                }
            }
        }
    }
}
