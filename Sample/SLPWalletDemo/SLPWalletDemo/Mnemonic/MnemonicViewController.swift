//
//  MnemonicViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class MnemonicViewController: UIViewController {
    
    var presenter: MnemonicPresenter?

    @IBOutlet weak var mnemonicLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mnemonic"
        
        presenter?.viewDidLoad()
    }
    
    func onGetMnemonic(_ output: String) {
        mnemonicLabel.text = output
    }
}
