//
//  Double+ExtensionsTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class DoubleTest: QuickSpec {
    override func spec() {
        describe("Double") {
            context("Converts") {
                it("should success") {
                    let bch: Double = 1.2
                    expect(bch.toInt()).to(equal(1))
                    expect(bch.toString()).to(equal("1.2"))
                    expect(bch.toSatoshis()).to(equal(120000000))
                }
            }
        }
    }
}
