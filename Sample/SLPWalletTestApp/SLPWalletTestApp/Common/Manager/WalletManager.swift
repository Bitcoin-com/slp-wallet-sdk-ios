//
//  WalletManager.swift
//  SLPWalletTestApp
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import SLPWallet

class WalletManager: SLPWalletDelegate {
    static let shared = WalletManager()
    
    var wallet: SLPWallet
    
    init() {
        do {
            wallet = try SLPWallet(.mainnet)
            wallet.delegate = self
            wallet.scheduler.resume()
        } catch {
            fatalError("It should be able to construct a wallet")
        }
    }
    
    func onUpdatedToken(_ token: [String : SLPToken]) {
        // Notify
    }
}
