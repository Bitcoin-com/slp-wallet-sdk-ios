//
//  TokenViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class TokenViewController: UIViewController {

    var presenter: TokenPresenter?
    
    fileprivate var rightBarButtonCancelItem: UIBarButtonItem?
    fileprivate var rightBarButtonSendItem: UIBarButtonItem?
    
//    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightBarButtonSendItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(didPushSend))
        rightBarButtonCancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didPushCancel))
        
        navigationItem.rightBarButtonItem = rightBarButtonSendItem
        
        sendView.isHidden = true

        presenter?.viewDidLoad()
    }
    
    @objc func didPushCancel() {
        presenter?.didPushCancel()
    }
    
    @objc func didPushSend() {
        presenter?.didPushSend()
    }
    
    func onViewDidLoad(_ output: TokenPresenterOutput) {
        title = output.tokenOutput.name
        
//        idLabel.text = output.tokenOutput.id
        nameLabel.text = output.tokenOutput.name
        tickerLabel.text = output.tokenOutput.ticker
        
        onGetBalance(output.tokenOutput.balance, ticker: output.tokenOutput.ticker)
    }
    
    func onGetBalance(_ balance: Double, ticker: String)  {
        balanceLabel.text = "\(balance.description) \(ticker)"
    }
    
    func onSuccessSend(_ txid: String) {
        let alert = UIAlertController(title: "Token sent", message: "Please, Visit our block explorer to see your transaction", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: {
                self.hideSend()
            })
        }))
        
        alert.addAction(UIAlertAction(title: "View on explorer", style: .default, handler: { _ in
            self.hideSend()
            guard let url = URL(string: "https://explorer.bitcoin.com/bch/tx/\(txid)") else {
                return
            }
            UIApplication.shared.open(url)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func onError(_ error: Error) {
        // Enable to send again
        confirmButton.isEnabled = true
        
        let alert = UIAlertController(title: "Send token", message: "Error, \(error.localizedDescription)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didPushConfirm(_ sender: Any) {
        guard let amount = amountTextField?.text
            , let toAddress = toAddressTextField?.text else {
                return
        }
        
        confirmButton.isEnabled = false
        
        self.presenter?.didPushSend(amount, toAddress: toAddress)
    }
    
    func hideSend() {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonSendItem
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sendView.isHidden = true
        }, completion: { _ in
            self.amountTextField.text = ""
            self.toAddressTextField.text = ""
        })
    }
    
    func showSend() {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonCancelItem
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sendView.isHidden = false
        }, completion: { _ in
            self.confirmButton.isEnabled = true
        })
    }
}
