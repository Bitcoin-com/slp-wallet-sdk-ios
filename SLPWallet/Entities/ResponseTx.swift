//
//  ResponseTx.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

struct ResponseTx: Codable {
    let txid: String
    let vin: [ResponseInput]
    let vout: [ResponseOutput]
    let confirmations: Int
    let time: Int
    let fees: Double
    
    struct ResponseInput: Codable {
        let addr: String
        let valueSat: Int
    }
    
    struct ResponseOutput: Codable {
        let value: String
        let n: Int
        let scriptPubKey: ResponseScriptPubKey
    }
    
    struct ResponseScriptPubKey: Codable {
        let addresses: [String]?
        let hex: String
        let asm: String
    }
}
