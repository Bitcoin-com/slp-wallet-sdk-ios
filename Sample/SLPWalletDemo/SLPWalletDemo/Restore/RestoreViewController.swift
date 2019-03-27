//
//  RestoreViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import Lottie

class RestoreViewController: UIViewController {
    
    var presenter: RestorePresenter?

    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var mnemonicTextfield: UITextField!
    @IBOutlet weak var bgAnimationView: UIView!
    
    var animationView: LOTAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mnemonicTextfield.autocorrectionType = .no
        mnemonicTextfield.autocapitalizationType = .none
        mnemonicTextfield.becomeFirstResponder()
        mnemonicTextfield.delegate = self
        
        title = "Restore"
        
        hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func didPushRestore(_ sender: Any) {
        presenter?.didPushRestore(mnemonicTextfield.text ?? "")
    }
    
    func onSuccess() {
        errorLabel.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        let buttonHeight = screenHeight - screenHeight/2 - screenWidth/2
        
        let skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.tintColor = .white
        skipButton.addTarget(self, action: #selector(didPushSkip), for: .touchUpInside)
        skipButton.frame = CGRect(x: 0, y: screenHeight/2 + screenWidth/2, width: screenWidth, height: buttonHeight)
        
        let bgView = UIView(frame: view.bounds)
        bgView.backgroundColor = .black
        let animationView = LOTAnimationView(name: "rocket_success_animation")
        animationView.frame = CGRect(x: 0, y: screenHeight/2 - screenWidth/2, width: screenWidth, height: screenWidth)
        self.animationView = animationView
        
        view.addSubview(bgView)
        view.addSubview(skipButton)
        view.addSubview(animationView)
        
        animationView.play(completion: { [weak self] _ in
            self?.navigationController?.navigationBar.isHidden = false
            self?.presenter?.didSuccess()
        })
    }
    
    @objc func didPushSkip() {
        animationView?.stop()
    }
    
    func onError() {
        let animationView = LOTAnimationView(name: "shock_animation")
        animationView.frame = bgAnimationView.bounds
        bgAnimationView.addSubview(animationView)
        errorLabel.isHidden = false
        
        animationView.play(completion: { _ in
            animationView.removeFromSuperview()
        })
    }
}

extension RestoreViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didPushRestore(textField.text ?? "")
        return true
    }
}
