//
//  Account.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import BitcoinKit

internal struct Account {
    let privKey: PrivateKey
    let cashAddress: String
}
