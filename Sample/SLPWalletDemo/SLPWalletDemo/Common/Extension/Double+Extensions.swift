//
//  Double+Extensions.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/16.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

extension Double {
    func toCurrency(ticker: String, decimal: Int) -> String {
        let balance = NSDecimalNumber(value: self)
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.numberStyle = .currency
        nf.maximumFractionDigits = decimal
        nf.currencySymbol = "\(ticker) "
        return nf.string(from: balance) ?? ""
    }
}
