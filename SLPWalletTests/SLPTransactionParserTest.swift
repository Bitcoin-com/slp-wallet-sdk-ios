//
//  SLPTransactionParserTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/25.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet

class SLPTransactionParserTest: QuickSpec {
    override func spec() {
        describe("SLPTransactionParser") {
            context("Parse a transaction GENESIS") {
                
                it("should success") {
                    let path = Bundle(for: type(of: self)).path(forResource: "tx_details_genesis_tst", ofType: "json")
                    let url = URL(fileURLWithPath: path!)
                    
                    let data = try! Data(contentsOf: url)
                    let tx = try! JSONDecoder().decode(RestService.ResponseTx.self, from: data)
                    
                    guard let parsedData = SLPTransactionParser.parse(tx, vouts: [1, 2]) else {
                        fail()
                        return
                    }
                    
                    // Token
                    expect(parsedData.token.tokenId).to(equal("9cc1cf24e502554d2d3d09918c27decda2c260762961acd469c5473fbcfe192e"))
                    expect(parsedData.token.tokenName).to(equal("Try! Swift Token"))
                    expect(parsedData.token.tokenTicker).to(equal("TST"))
                    expect(parsedData.token.decimal).to(equal(2))
                    
                    // Token UTXOs
                    expect(parsedData.token.utxos.first).toNot(beNil())
                    
                    guard let utxo = parsedData.token.utxos.first else {
                        fail()
                        return
                    }
                    
                    expect(utxo.txid).to(equal("9cc1cf24e502554d2d3d09918c27decda2c260762961acd469c5473fbcfe192e"))
                    expect(utxo.rawTokenQty).to(equal(100000000000))
                    expect(utxo.satoshis).to(equal(546))
                    expect(utxo.cashAddress).to(equal("bitcoincash:qp4zxnnce2wy8ackzc29wtjp2xw9e6sgyvuv77vvmh"))
                    expect(utxo.index).to(equal(1))
                    
                    // Baton
                    expect(parsedData.token.mintUTXO).toNot(beNil())
                    expect(parsedData.token.mintUTXO?.txid).to(equal("9cc1cf24e502554d2d3d09918c27decda2c260762961acd469c5473fbcfe192e"))
                    expect(parsedData.token.mintUTXO?.cashAddress).to(equal("bitcoincash:qp4zxnnce2wy8ackzc29wtjp2xw9e6sgyvuv77vvmh"))
                    expect(parsedData.token.mintUTXO?.satoshis).to(equal(546))
                    expect(parsedData.token.mintUTXO?.index).to(equal(2))
                    
                    // UTXOs
                    expect(parsedData.utxos.count).to(equal(0))
                }
            }
        }
        
        context("Parse a transaction SEND") {
            
            it("should success") {
                let path = Bundle(for: type(of: self)).path(forResource: "tx_details_send_tst", ofType: "json")
                let url = URL(fileURLWithPath: path!)
                
                let data = try! Data(contentsOf: url)
                let tx = try! JSONDecoder().decode(RestService.ResponseTx.self, from: data)
                
                guard let parsedData = SLPTransactionParser.parse(tx, vouts: [2, 3]) else {
                    fail()
                    return
                }
                
                // Token
                expect(parsedData.token.tokenId).to(equal("9cc1cf24e502554d2d3d09918c27decda2c260762961acd469c5473fbcfe192e"))
                expect(parsedData.token.tokenName).to(beNil())
                expect(parsedData.token.tokenTicker).to(beNil())
                expect(parsedData.token.decimal).to(beNil())
                
                // Token UTXOs
                expect(parsedData.token.utxos.first).toNot(beNil())
                
                guard let tokenUTXO = parsedData.token.utxos.first else {
                    fail()
                    return
                }
                
                expect(tokenUTXO.txid).to(equal("a9f639148662ca6376c3650f3d7e6dffbe9a477cf947499bfcb2c85412331c2e"))
                expect(tokenUTXO.rawTokenQty).to(equal(15080066))
                expect(tokenUTXO.satoshis).to(equal(546))
                expect(tokenUTXO.cashAddress).to(equal("bitcoincash:qzdwxdtprwxhynpvcqngtupp3tn58smte5z2yfqe0v"))
                expect(tokenUTXO.index).to(equal(2))
                
                // Baton
                expect(parsedData.token.mintUTXO).to(beNil())
                
                // UTXOs
                expect(parsedData.utxos.first).toNot(beNil())
                
                guard let utxo = parsedData.utxos.first else {
                    fail()
                    return
                }
                
                expect(utxo.txid).to(equal("a9f639148662ca6376c3650f3d7e6dffbe9a477cf947499bfcb2c85412331c2e"))
                expect(utxo.satoshis).to(equal(192966))
                expect(utxo.cashAddress).to(equal("bitcoincash:qqga5ljshfug5g27532d9xc0w55yxdjzwygw62c0nk"))
                expect(utxo.index).to(equal(3))
            }
        }
        
        context("Parse a transaction MINT") {
            
            it("should success") {
                let path = Bundle(for: type(of: self)).path(forResource: "tx_details_mint_lvl001", ofType: "json")
                let url = URL(fileURLWithPath: path!)
                
                let data = try! Data(contentsOf: url)
                let tx = try! JSONDecoder().decode(RestService.ResponseTx.self, from: data)
                
                guard let parsedData = SLPTransactionParser.parse(tx, vouts: [1, 2]) else {
                    fail()
                    return
                }
                
                // Token
                expect(parsedData.token.tokenId).to(equal("d5efb237f43a822ede2086bbefca44f1157b7adf2ddeed87c4b294bd136d1d36"))
                expect(parsedData.token.tokenName).to(beNil())
                expect(parsedData.token.tokenTicker).to(beNil())
                expect(parsedData.token.decimal).to(beNil())
                
                // Token UTXOs
                expect(parsedData.token.utxos.first).toNot(beNil())
                
                guard let tokenUTXO = parsedData.token.utxos.first else {
                    fail()
                    return
                }
                
                expect(tokenUTXO.txid).to(equal("c3b72361cee1a7ed5d0911714da7439313eaf22fde842f871656e4d438eba7d1"))
                expect(tokenUTXO.rawTokenQty).to(equal(1))
                expect(tokenUTXO.satoshis).to(equal(546))
                expect(tokenUTXO.cashAddress).to(equal("bitcoincash:qzsn8qeupph6pf8kyn2x79afff7pygzfvqnjwvhmzm"))
                expect(tokenUTXO.index).to(equal(1))
                
                // Baton
                expect(parsedData.token.mintUTXO).toNot(beNil())
                expect(parsedData.token.mintUTXO?.txid).to(equal("c3b72361cee1a7ed5d0911714da7439313eaf22fde842f871656e4d438eba7d1"))
                expect(parsedData.token.mintUTXO?.cashAddress).to(equal("bitcoincash:qrgwrx7hvd27jqz8q5fmgr4kg5cy76yp05a3prllmr"))
                expect(parsedData.token.mintUTXO?.satoshis).to(equal(546))
                expect(parsedData.token.mintUTXO?.index).to(equal(2))
                
                // UTXOs
                expect(parsedData.utxos.first).to(beNil())
            }
        }
    }
}
