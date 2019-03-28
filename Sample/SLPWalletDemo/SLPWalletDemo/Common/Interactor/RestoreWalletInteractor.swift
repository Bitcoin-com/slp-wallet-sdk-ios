//
//  RestoreWalletInteractor.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import SLPWallet

class RestoreWalletInteractor {
    func restore(_ mnemonic: String) -> Bool {
        return WalletManager.shared.restore(mnemonic)
    }
}
