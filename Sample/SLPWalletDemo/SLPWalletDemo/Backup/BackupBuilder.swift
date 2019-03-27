//
//  BackupBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class BackupBuilder: BaseBuilder {
    
    func provide() -> UIViewController {
        let viewController = UIStoryboard(name: "Backup", bundle: nil).instantiateViewController(withIdentifier: "BackupViewController") as! BackupViewController
        
        let presenter = BackupPresenter()
        
        presenter.viewDelegate = viewController
        
        viewController.presenter = presenter
        
        return viewController
    }
}
