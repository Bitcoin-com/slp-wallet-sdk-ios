//
//  ResponseUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

struct ResponseUTXO: Codable {
    let txid: String
    let vout: Int
    let satoshis: Int
    let address: String
    let confirmations: Int
    let scriptPubKey: String
}
