//
//  TokenViewController.swift
//  SLPWalletTestApp
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class TokenViewController: UITableViewController {

    var presenter: TokenPresenter?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(didPushSend))

        presenter?.viewDidLoad()
    }
    
    @objc func didPushSend() {
        presenter?.didPushSend()
    }
    
    func onViewDidLoad(_ output: TokenPresenterOutput) {
        title = output.tokenOutput.name
        
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
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "View on explorer", style: .default, handler: { _ in
            guard let url = URL(string: "https://explorer.bitcoin.com/bch/tx/\(txid)") else {
                return
            }
            UIApplication.shared.open(url)
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func onError(_ error: Error) {
        print(WalletManager.shared.wallet.getGas())
//        WalletManager.shared.wallet.tokens.forEach({ print($0.value.getGas())})
        let alert = UIAlertController(title: "Send token", message: "Error, \(error.localizedDescription)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func presentAmount() {
        var amountTextField: UITextField?
        var toAddressTextField: UITextField?
        
        let alert = UIAlertController(title: "Send token", message: "Please, enter an amount and a destination", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Amount"
            amountTextField = textField
        }
        
        alert.addTextField { textField in
            textField.placeholder = "To address"
            toAddressTextField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { alertAction in
            
            guard let amount = amountTextField?.text
                , let toAddress = toAddressTextField?.text else {
                    return
            }
            
            self.presenter?.didPushSend(amount, toAddress: toAddress)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
