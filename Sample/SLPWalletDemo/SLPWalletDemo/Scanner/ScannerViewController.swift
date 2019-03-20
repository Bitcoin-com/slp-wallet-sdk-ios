//
//  ScannerViewController.swift
//  SLPWalletDemo
//
//  Created by Angel Mortega on 2019/03/20.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import Lottie

class ScannerViewController: UIViewController {
    
    var presenter: ScannerPresenter?
    
    @IBOutlet weak var mnemonicLabel: UILabel!
    @IBOutlet weak var bgAnimationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scanner"
        
        presenter?.viewDidLoad()
    }

}
