//
//  UserDefaults+Extensions.swift
//  SLPSDK
//
//  Created by Jean-Baptiste Dominguez on 2019/02/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

extension UserDefaults {
    public static var SLPWallet: UserDefaults {
        return UserDefaults(suiteName: "SLPWallet")!
    }
}
