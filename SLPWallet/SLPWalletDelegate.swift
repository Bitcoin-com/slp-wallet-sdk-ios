//
//  SLPWalletDelegate.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/01.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

public protocol SLPWalletDelegate {
    func onTokens(_ tokens: [String:SLPToken])
}
