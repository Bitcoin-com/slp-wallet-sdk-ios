//
//  MnemonicBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class MnemonicBuilder {
    
    static func provide() -> MnemonicViewController {
        let viewController = UIStoryboard(name: "Mnemonic", bundle: nil).instantiateViewController(withIdentifier: "MnemonicViewController") as! MnemonicViewController
        
        let presenter = MnemonicPresenter()
        
        presenter.viewDelegate = viewController
        
        viewController.presenter = presenter
        
        return viewController
    }
}
