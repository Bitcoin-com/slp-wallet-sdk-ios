//
//  TokenViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import IGIdenticon
import Lottie
import SLPWallet

class TokenViewController: UIViewController {

    var presenter: TokenPresenter?
    
    fileprivate var rightBarButtonCancelItem: UIBarButtonItem?
    fileprivate var rightBarButtonSendItem: UIBarButtonItem?
    fileprivate var confirmLoadingAnimationView: LOTAnimationView?
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        rightBarButtonSendItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(didPushSend))
        rightBarButtonCancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didPushCancel))
        
        navigationItem.rightBarButtonItem = rightBarButtonSendItem
        
        sendView.isHidden = true
        
        let confirmLoadingAnimationView = LOTAnimationView(name: "button_loading_animation")
        confirmLoadingAnimationView.frame = confirmButton.bounds
        confirmLoadingAnimationView.isHidden = true
        confirmLoadingAnimationView.loopAnimation = true
        confirmButton.addSubview(confirmLoadingAnimationView)
        
        self.confirmLoadingAnimationView = confirmLoadingAnimationView
        
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
        
        idLabel.text = output.tokenOutput.id
        nameLabel.text = output.tokenOutput.name
        tickerLabel.text = output.tokenOutput.ticker
        decimalLabel.text = output.tokenOutput.decimal.description
        
        iconImageView.image = Identicon().icon(from: output.tokenOutput.id, size: CGSize(width: 48, height: 48))
        iconImageView.layer.cornerRadius = 24
        iconImageView.layer.borderColor = UIColor.white.cgColor
        iconImageView.layer.borderWidth = 1
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = UIColor.white
        
        onGetBalance(output.tokenOutput.balance)
    }
    
    func onGetBalance(_ balance: String)  {
        balanceLabel.text = balance
    }
    
    func onSuccessSend(_ txid: String) {
        let alert = UIAlertController(title: "Token sent", message: "Please, Visit our block explorer to see your transaction", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            self.dismissSend()
        }))
        
        alert.addAction(UIAlertAction(title: "View on explorer", style: .default, handler: { _ in
            self.dismissSend()
            
            guard let url = URL(string: "https://explorer.bitcoin.com/bch/tx/\(txid)") else {
                return
            }
            
            UIApplication.shared.open(url)
        }))
        
        present(alert, animated: true)
    }
    
    func onError(_ error: Error) {
        // Enable to send again
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.isEnabled = true
        confirmLoadingAnimationView?.stop()
        confirmLoadingAnimationView?.isHidden = true
        
        var message: String
        if let error = error as? SLPTransactionBuilderError {
            switch error {
            case .TO_ADDRESS_INVALID:
                message = "Address is invalid."
            case .GAS_INSUFFICIENT:
                message = "Insufficent BCH available."
            case .INSUFFICIENT_FUNDS:
                message = "Insufficent tokens available."
            case .TOKEN_NOT_FOUND:
                message = "Token was not found."
            default:
                message = "Transaction building has failed."
            }
        } else if error is TokenPresenterError {
            message = "Amount is invalid."
        } else {
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: "Send Token Error", message: "\(message)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didPushGenesisExplorer(_ sender: Any) {
        presenter?.didPushGenesisExplorer()
    }
    
    @IBAction func didPushScanner(_ sender: Any) {
        presenter?.didPushScanner(sender)
    }
    
    @IBAction func didPushPaste(_ sender: Any) {
        if let toAddress = UIPasteboard.general.string {
            toAddressTextField.text = toAddress
        }
    }
    
    
    @IBAction func didPushConfirm(_ sender: Any) {
        guard let amount = amountTextField?.text
            , let toAddress = toAddressTextField?.text else {
                return
        }
        
        // UI
        dismissKeyboard()
        confirmButton.setTitle(nil, for: .normal)
        confirmButton.isEnabled = false
        confirmLoadingAnimationView?.isHidden = false
        confirmLoadingAnimationView?.play()
        
        // Send action
        self.presenter?.didPushConfirm(amount, toAddress: toAddress)
    }
    
    func dismissSend() {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonSendItem
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sendView.isHidden = true
        }, completion: { _ in
            self.amountTextField.text = ""
            self.toAddressTextField.text = ""
            self.dismissKeyboard()
        })
    }
    
    func presentSend() {
        navigationItem.rightBarButtonItem = rightBarButtonCancelItem
        confirmLoadingAnimationView?.isHidden = true
        confirmLoadingAnimationView?.stop()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sendView.isHidden = false
        }, completion: { _ in
            self.confirmButton.setTitle("Confirm", for: .normal)
            self.confirmButton.isEnabled = true
            self.amountTextField.becomeFirstResponder()
        })
    }
}

extension TokenViewController : ScannerDelegate {
    func onScanResult(value: String?) {
        guard let value = value else {
            return
        }
        
        toAddressTextField.text = value
    }
}
