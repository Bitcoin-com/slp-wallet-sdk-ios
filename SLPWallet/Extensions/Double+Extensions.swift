//
//  Double+Extensions.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/28.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

extension Double {
    func toSatoshis() -> Int64 {
        let double = NSDecimalNumber(value: self).multiplying(by: 100000000).doubleValue
        return Int64(double.rounded())
    }
    
    func toString() -> String {
        return String(self)
    }
    
    func toInt() -> Int {
        return NSDecimalNumber(value: self).intValue
    }
}
