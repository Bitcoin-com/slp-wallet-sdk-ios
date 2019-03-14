//
//  UIViewController+Extensions.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/14.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
