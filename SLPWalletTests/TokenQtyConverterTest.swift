//
//  TokenQtyConverterTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class TokenQtyConverterTest: QuickSpec {
    override func spec() {
        describe("TokenQtyConverter") {
            context("Convert to quantity") {
                it("should success") {
                    expect(TokenQtyConverter.convertToQty(123456, decimal: 3)).to(equal(123.456))
                    expect(TokenQtyConverter.convertToQty(123456000, decimal: 3)).to(equal(123456))
                }
            }
            
            context("Convert to raw quantity") {
                it("should success") {
                    expect(TokenQtyConverter.convertToRawQty(123.456, decimal: 3)).to(equal(123456))
                    expect(TokenQtyConverter.convertToRawQty(123456, decimal: 3)).to(equal(123456000))
                }
            }
            
            context("Convert to data") {
                it("should success") {
                    expect(TokenQtyConverter.convertToData(1152921504606846976)).toNot(beNil())
                }
            }
        }
    }
}
