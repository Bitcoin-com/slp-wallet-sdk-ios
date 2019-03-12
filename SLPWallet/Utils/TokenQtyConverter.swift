//
//  TokenQtyConverter.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/04.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

class TokenQtyConverter {
    
    static func convertToQty(_ rawAmount: Int, decimal: Int) -> Double {
        let amount = decimal > 0 ? Double(rawAmount) / pow(Double(10), Double(decimal)) : Double(rawAmount)
        return amount
    }
    
    static func convertToRawQty(_ amount: Double, decimal: Int) -> Int {
        let rawAmount = decimal > 0 ? Int(amount * pow(Double(10), Double(decimal))) : Int(amount)
        return rawAmount
    }
    
    static func convertToData(_ rawAmount: Int) -> Data? {
        
        // Convert the amount in hexa
        let amountInHex = String(rawAmount, radix: 16)
        
        // Create the empty hex
        var amountInHex16 = [Character](repeating: "0", count: 16)
        for (i, value) in amountInHex.enumerated() {
            amountInHex16[amountInHex16.count - amountInHex.count + i] = value
        }
        
        return Data(hex: String(amountInHex16))
    }
}
