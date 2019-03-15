//
//  String+Extensions.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/28.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

extension String {
    func toSatoshis() -> Int64 {
        return self.toDouble().toSatoshis()
    }
    
    func toDouble() -> Double {
        return NSDecimalNumber(string: self).doubleValue
    }
}
