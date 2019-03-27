//
//  StorageProvider.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

protocol StorageProvider {
    func remove(_ key: String) throws
    func setString(_ value: String, key: String) throws
    func getString(_ key: String) throws -> String?
}
