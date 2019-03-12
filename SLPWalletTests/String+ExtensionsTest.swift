//
//  String+ExtensionsTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class StringTest: QuickSpec {
    override func spec() {
        describe("String") {
            context("Converts") {
                it("should success") {
                    let bch: String = "1.2"
                    expect(bch.toSatoshis()).to(equal(120000000))
                    
                    let whatEver: String = "whatever"
                    expect(whatEver.toSatoshis()).to(equal(0))
                }
            }
        }
    }
}
