//
//  Config.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

enum ConfigError: Error {
    case URL_MALFORMATTED
}

enum ConfigKey: String {
    case URL
}

public class Config {
    // Singleton
    static var shared = Config()
    var restUrl: URL
    
    init() {
        guard let url = UserDefaults.SLPWallet.getString(forKey: ConfigKey.URL.rawValue),
              let restUrl = URL(string: url) else {
                self.restUrl = URL(string: "https://trest.bitcoin.com")!
                return
        }
        self.restUrl = restUrl
    }
    
    static public func setRestUrl(_ url: String) throws {
        guard let restUrl = URL(string: url) else {
            throw ConfigError.URL_MALFORMATTED
        }
        
        shared.restUrl = restUrl
        UserDefaults.SLPWallet.setString(url, forKey: ConfigKey.URL.rawValue)
    }
}
