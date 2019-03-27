//
//  SLPWalletConfigTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class SLPWalletConfigTest: QuickSpec {
    override func spec() {
        describe("SLPWalletConfig") {
            context("SetAPIKey") {
                it("should success") {
                    expect(SLPWalletConfig.shared.restAPIKey).to(beNil())
                    
                    SLPWalletConfig.setRestAPIKey("test")
                    expect(SLPWalletConfig.shared.restAPIKey).to(equal("test"))
                }
            }
        }
    }
}
