//
//  ScannerRouter.swift
//  SLPWalletDemo
//
//  Created by Angel Mortega on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

class ScannerRouter: BaseRouter {
    
    func transitBackToToken() {
        viewController?.dismiss(animated: true)
    }
}
