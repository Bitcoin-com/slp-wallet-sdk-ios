//
//  ScannerBuilder.swift
//  SLPWalletDemo
//
//  Created by Angel Mortega on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class ScannerBuilder {
    
    static func provide() -> ScannerViewController {
        let viewController = UIStoryboard(name: "Scanner", bundle: nil).instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        
        let presenter = ScannerPresenter()
        
        presenter.viewDelegate = viewController
        
        viewController.presenter = presenter
        
        return viewController
    }
}
