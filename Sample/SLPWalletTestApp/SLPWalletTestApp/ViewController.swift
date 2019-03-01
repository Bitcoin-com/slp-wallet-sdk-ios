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
    
    fileprivate var wallet: SLPWallet = SLPWallet("Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto", network: .mainnet)
    fileprivate var tokens = [String:SLPToken]()
    fileprivate var selectedToken: SLPToken?
    
    @IBOutlet weak var cashAddressLabel: UILabel!
    @IBOutlet weak var slpAddressLabel: UILabel!
    
    @IBOutlet weak var tokenSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallet.delegate = self
        
        setupWallet()
    }
    
    func setupWallet() {
        self.tokenSegmentControl.removeAllSegments()
        cashAddressLabel.text = wallet.cashAddress
        slpAddressLabel.text = wallet.slpAddress
    }
    
    func onUpdatedSelectedToken(_ token: SLPToken) {
        balanceLabel.text = token.getBalance().description
        gasLabel.text = token.getGas().description
    }
    
    @IBAction func didSelectToken(_ sender: Any) {
        guard tokens.keys.count > tokenSegmentControl.selectedSegmentIndex else {
            return
        }
        
        let keys = Array(tokens.keys)
        selectedToken = self.tokens[keys[tokenSegmentControl.selectedSegmentIndex]]
        onUpdatedSelectedToken(selectedToken!)
    }
    
    func onNewToken(_ token:  SLPToken) {
        self.tokens[token.tokenId] = token
        self.tokenSegmentControl.insertSegment(withTitle: token.tokenTicker, at: 0, animated: true)
    }
}

extension ViewController: SLPWalletDelegate {
    
    func onUpdatedToken(_ tokens: [String:SLPToken]) {
        tokens.forEach({ tokenId, token in
            if self.tokens[tokenId] == nil {
                onNewToken(token)
            } else if self.tokens[tokenId]!.getBalance() != tokens[tokenId]!.getBalance() {
                self.tokens[tokenId] = token
                
                if let selectedToken = self.selectedToken
                    , selectedToken.tokenId == tokenId {
                    self.selectedToken = token
                    onUpdatedSelectedToken(token)
                }
            }
            
        })
    }
}

