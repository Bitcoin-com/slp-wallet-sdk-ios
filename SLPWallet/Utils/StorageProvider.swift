
//
//  StorageProvider.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/12.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import KeychainAccess

class StorageProvider {
    fileprivate let keychain: Keychain = {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            fatalError("Should initialize properly to start using this SDK")
        }
        return Keychain(service: bundleId)
    }()
    
    func setString(_ value: String, key: String) throws {
        try keychain.set(value, key: key)
    }
    
    func getString(_ key: String) throws -> String? {
        return try keychain.get(key)
    }
}
