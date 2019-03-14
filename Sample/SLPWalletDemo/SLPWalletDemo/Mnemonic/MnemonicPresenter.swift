//
//  MnemonicPresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

class MnemonicPresenter {
    weak var viewDelegate: MnemonicViewController?
    
    init() {}
    
    func viewDidLoad() {
        let mnemonic = WalletManager.shared.wallet.mnemonic
        viewDelegate?.onGetMnemonic(mnemonic.joined(separator: ", "))
    }
}
