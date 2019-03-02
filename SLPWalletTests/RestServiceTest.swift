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
import BitcoinKit

class RestServiceTest: QuickSpec {
    override func spec() {
        describe("RestService") {
            
            it("Fetch UTXO") {
                let utxos = try! RestService
                    .fetchUTXOs("bitcoincash:qzk92nt0xdxc9qy3yj53h9rjw8dk0s9cqqucfqpcd6")
                    .toBlocking()
                    .single()
                expect(utxos).notTo(beNil())
                expect(utxos.scriptPubKey).to(equal("76a914ac554d6f334d82809124a91b947271db67c0b80088ac"))
            }
            
            it("Fetch TxDetails") {
                    let txs = try! RestService
                        .fetchTxDetails(["ce7f87ac5d086ad1c736c472ce5bc75f020bf22d3e2ed8603c675a6517b9c1cd"])
                        .toBlocking()
                        .single()
                    expect(txs).notTo(beNil())
            }
        }
    }
}
