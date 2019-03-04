//
//  ViewController.swift
//  SLPWalletTestApp
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class ViewController: UIViewController {
    
    fileprivate var wallet: SLPWallet = SLPWallet("machine cannon man rail best deliver draw course time tape violin tone", network: .mainnet)
    fileprivate var tokens = [SLPToken]()
    
    fileprivate var tokenIds = [String]()
    fileprivate var selectedTokenId: String?
    fileprivate var selectedTokenBalance: Double?
    
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var cashAddressLabel: UILabel!
    @IBOutlet weak var slpAddressLabel: UILabel!
    
    @IBOutlet weak var tokenSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var amount: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallet.delegate = self
        wallet.scheduler.resume()
        
        setupWallet()
    }
    
    func setupWallet() {
        tokenSegmentControl.removeAllSegments()
        cashAddressLabel.text = wallet.cashAddress
        slpAddressLabel.text = wallet.slpAddress
    }
    
    func onUpdatedSelectedToken(_ token: SLPToken) {
        selectedTokenBalance = token.getBalance()
        balanceLabel.text = token.getBalance().description
        gasLabel.text = (wallet.getGas() + token.getGas()).description
        tokenNameLabel.text = token.tokenName
    }
    
    @IBAction func sendToken(_ sender: Any) {
        guard let address = address.text
            , let amountStr = amount.text
            , let amount = Double(amountStr)
            , let tokenId = selectedTokenId else {
            return
        }
//        wallet.se
    }
    
    @IBAction func didSelectToken(_ sender: Any) {
        guard tokens.count > tokenSegmentControl.selectedSegmentIndex else {
            return
        }
        
        let token = tokens[tokenSegmentControl.selectedSegmentIndex]
        selectedTokenId = token.tokenId
        onUpdatedSelectedToken(token)
    }
    
    func onNewToken(_ token:  SLPToken) {
        guard let tokenId = token.tokenId else {
            return
        }
        
        tokens.append(token)
        tokenIds.append(tokenId)
        
        tokenSegmentControl.insertSegment(withTitle: token.tokenTicker, at: tokens.count, animated: true)
    }
}

extension ViewController: SLPWalletDelegate {
    
    func onUpdatedToken(_ tokens: [String:SLPToken]) {
        tokens.forEach({ tokenId, token in
            if tokenIds.firstIndex(of: tokenId) != nil {
                
                // If a token is selected & balance updated, update the UI.
                guard let selectedTokenId = self.selectedTokenId
                    , let selectedTokenBalance = self.selectedTokenBalance
                    , selectedTokenId == token.tokenId
                    , selectedTokenBalance != token.getBalance() else {
                        return
                }
                
                onUpdatedSelectedToken(token)
            } else {
                onNewToken(token)
            }
        })
    }
}

