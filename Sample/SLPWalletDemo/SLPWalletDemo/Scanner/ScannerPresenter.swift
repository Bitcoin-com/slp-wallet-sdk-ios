//
//  ScannerPresenter.swift
//  SLPWalletDemo
//
//  Created by Angel Mortega on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class ScannerPresenter {
    
    weak var viewDelegate: ScannerViewController?
    
    fileprivate var mnemonic: String?
    
    init() {}
    
    func viewDidLoad() {
        print("Scanner Presenter Loaded!")
    }
    
}

