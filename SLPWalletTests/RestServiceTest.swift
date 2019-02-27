//
//  RestServiceTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import SLPWallet
import Nimble
import Quick
import RxBlocking

class RestServiceTest: QuickSpec {
    override func spec() {
        describe("RestService") {
            describe("Fetch UTXO") {
                it("Address with 1 utxo") {
                    expect(try! RestService
                        .fetchUTXOs("bitcoincash:qrkn34tllug35tfs655e649asx4udw4dccaygv6wcr")
                        .toBlocking()
                        .single()).to(haveCount(1))
                }
            }
        }
    }
}
