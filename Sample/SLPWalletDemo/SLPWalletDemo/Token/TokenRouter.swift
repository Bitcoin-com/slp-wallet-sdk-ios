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
        let scannerViewController = ScannerBuilder.provide()
        viewController?.navigationController?.pushViewController(scannerViewController, animated: true)
    }
}
