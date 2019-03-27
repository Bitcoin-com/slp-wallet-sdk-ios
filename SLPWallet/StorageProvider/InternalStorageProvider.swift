//
//  UserDefaultStorageProvider.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

class InternalStorageProvider: StorageProvider {

    func remove(_ key: String) throws {
        UserDefaults.SLPWallet.removeObject(forKey: key)
    }
    
    func setString(_ value: String, key: String) throws {
        UserDefaults.SLPWallet.set(value, forKey: key)
    }
    
    func getString(_ key: String) throws -> String? {
        return UserDefaults.SLPWallet.getString(forKey: key)
    }
}
