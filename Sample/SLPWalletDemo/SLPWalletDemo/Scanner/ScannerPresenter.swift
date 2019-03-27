//
//  ScannerPresenter.swift
//  SLPWalletDemo
//
//  Created by Angel Mortega on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

protocol ScannerDelegate {
    func onScanResult(value: String?)
}

class ScannerPresenter {
    
    weak var viewDelegate: ScannerViewController?
    var router: ScannerRouter?
    var scannerDelegate: ScannerDelegate?
    
    fileprivate var mnemonic: String?
    
    init() {}
    
    func didNext(value: String) {
        scannerDelegate?.onScanResult(value: value)
        router?.transitBack()
    }
    
    func didPushClose() {
        router?.transitBack()
    }
    
}

