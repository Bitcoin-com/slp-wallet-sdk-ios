//
//  TokenRouter.swift
//  SLPWalletDemo
//
//  Created by Angel Mortega on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class TokenRouter: BaseRouter {
    
    func transitToScanner() {
        guard let scannerDelegate = viewController as? ScannerDelegate else {
            return
        }
        
        let scannerViewController = ScannerBuilder().provide(scannerDelegate)
        
        let navigationController = UINavigationController(rootViewController: scannerViewController)
        viewController?.navigationController?.present(navigationController, animated: true)
        
    }
}
