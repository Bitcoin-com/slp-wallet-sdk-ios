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
                let wallet = SLPWallet("Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto", network: .mainnet)
                
                expect(wallet.mnemonic).to(equal("Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto"))
                expect(wallet.cashAddress).to(equal("bitcoincash:qrkn34tllug35tfs655e649asx4udw4dccaygv6wcr"))
                expect(wallet.slpAddress).to(equal("simpleledger:qrkn34tllug35tfs655e649asx4udw4dcc3lrh0wxa"))
            }
            
            it("Fetch tokens") {
                let wallet = SLPWallet("Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto", network: .mainnet)
                let tokens = try! wallet
                    .fetchTokens()
                    .toBlocking()
                    .single()
                tokens.forEach({ key, token in
                    expect(token.tokenTicker).to(equal("UIOP2"))
                    expect(token.tokenName).to(equal("The UIOP V2"))
                    expect(token.decimal).to(equal(4))
                    expect(token.getBalance()).toNot(beNil())
                    expect(token.getGas()).toNot(beNil())
                    
//                    Check the output
//                    print("------------")
//                    print("TokenId: \(token.tokenId)")
//                    print("TokenTicker: \(token.tokenTicker ?? "-")")
//                    print("TokenName: \(token.tokenName ?? "-")")
//                    print("TokenDecimal: \(token.decimal ?? 0)")
//                    print("Balance: \(token.getBalance())")
//                    print("Gas: \(token.getGas())")
                })
            }
            
            it("Add token") {
                let wallet = SLPWallet("Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto", network: .mainnet)
                let token = SLPToken("3257135d7c351f8b2f46ab2b5e610620beb7a957f3885ce1787cffa90582f503")
                let newToken = try! wallet
                    .addToken(token)
                    .toBlocking()
                    .single()
                
                expect(newToken.tokenTicker).to(equal("UIOP2"))
                expect(newToken.tokenName).to(equal("The UIOP V2"))
                expect(newToken.decimal).to(equal(4))
                expect(newToken.getBalance()).toNot(beNil())
                expect(newToken.getGas()).toNot(beNil())
            }
        }
    }
}
