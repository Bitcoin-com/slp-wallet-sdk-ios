//
//  InternalStorageProviderTest.swift
//  SLPWalletTests
//
//  Created by Jean-Baptiste Dominguez on 2019/03/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Nimble
import Quick
@testable import SLPWallet
    
class InternalStorageProviderTest: QuickSpec {
    
    override func spec() {
        describe("InternalStorageProvider") {
            context("Get/Set/Remove String") {
                it("should success") {
                    let storageProvider = InternalStorageProvider()
                    
                    do {
                        try storageProvider.remove("test")
                        
                        var storedValue = try storageProvider.getString("test")
                        expect(storedValue).to(beNil())
                        
                        try storageProvider.setString("value", key: "test")
                        
                        storedValue = try storageProvider.getString("test")
                        expect(storedValue).to(equal("value"))
                    } catch {
                        fail()
                    }
                    
                }
            }
        }
    }
}
