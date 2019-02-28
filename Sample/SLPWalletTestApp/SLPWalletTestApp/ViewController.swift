//
//  ViewController.swift
//  SLPWalletTestApp
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet
import RxSwift

class ViewController: UIViewController {
    
    fileprivate let bag = DisposeBag()
    
    fileprivate var wallet = SLPWallet("Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto", network: .mainnet)
    
    @IBOutlet weak var cashAddressLabel: UILabel!
    @IBOutlet weak var slpAddressLabel: UILabel!
    
    @IBOutlet weak var tokenSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tokenSegmentControl.removeAllSegments()
        
        cashAddressLabel.text = wallet.cashAddress
        slpAddressLabel.text = wallet.slpAddress
        
        wallet.fetchTokens()
            .subscribe(onSuccess: { tokens in
                tokens.forEach({ key, token in
                    self.tokenSegmentControl.insertSegment(withTitle: token.tokenTicker, at: 0, animated: true)
                })
            }).disposed(by: bag)
    }
    
    @IBAction func didSelectToken(_ sender: Any) {
        let keys = Array(wallet.tokens.keys)
        
        guard tokenSegmentControl.selectedSegmentIndex < keys.count
            , keys.count > 0 else {
            return
        }
        
        let tokenId = keys[tokenSegmentControl.selectedSegmentIndex]
        guard let token = wallet.tokens[tokenId] else {
            return
        }
        
        balanceLabel.text = token.getBalance().description
        gasLabel.text = token.getGas().description
    }
    
    
}

