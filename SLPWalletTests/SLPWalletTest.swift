//
//  SLPWalletTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/02/28.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import SLPWallet
import Nimble
import Quick
import RxBlocking
import BitcoinKit

class SLPWalletTest: QuickSpec {
    override func spec() {
        describe("SLPWallet") {
            it("Create wallet") {
                let wallet = SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                
                expect(wallet.mnemonic).to(equal("machine cannon man rail best deliver draw course time tape violin tone"))
                expect(wallet.cashAddress).to(equal("bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6"))
                expect(wallet.slpAddress).to(equal("simpleledger:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqsrzm5cny"))
            }
            
            it("Fetch tokens") {
                let wallet = SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
                let tokens = try! wallet
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
            }
            
            it("Add token") {
                let wallet = SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
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
    }
}
