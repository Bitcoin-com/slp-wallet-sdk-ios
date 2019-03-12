//
//  UserDefault+ExtensionsTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class UserDefaultTest: QuickSpec {
    override func spec() {
        describe("UserDefault") {
            context("Get SLPWallet") {
                it("should success") {
                    expect(UserDefaults.SLPWallet).toNot(beNil())
                }
            }
        }
    }
}
