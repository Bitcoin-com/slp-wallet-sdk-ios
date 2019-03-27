//
//  SLPWalletConfig.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public class SLPWalletConfig {
    
    static var shared = SLPWalletConfig()
    var restAPIKey: String?
    
    
    public static func setRestAPIKey(_ apiKey: String) {
        // Any throws for UserDefaults, force wrap is safe
        SLPWalletConfig.shared.restAPIKey = apiKey
    }
}
