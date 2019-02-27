//
//  ResponseUTXO.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

public struct ResponseUTXO: Codable {
    public let txid: String
    public let vout: Int
    public let satoshis: Int
    public let address: String
    public let confirmations: Int
    public let scriptPubKey: String
}
