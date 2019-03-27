//
//  BackupPresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class BackupPresenter {
    
    weak var viewDelegate: BackupViewController?
    
    fileprivate var mnemonic: String?
    
    init() {}
    
    func viewDidLoad() {
        let mnemonic = WalletManager.shared.wallet.mnemonic.joined(separator: " ")
        self.mnemonic = mnemonic
        
        viewDelegate?.onGetMnemonic(mnemonic)
    }
    
    func didPushCopy() {
        guard let mnemonic = self.mnemonic else {
            return
        }

        UIPasteboard.general.string = mnemonic
    }
}
