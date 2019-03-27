//
//  SettingsRouter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class SettingsRouter: BaseRouter {
    
    func transitTo(_ builder: BaseBuilder) {
        let newViewController = builder.provide()
        viewController?.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func transitTo(_ settingViewController: UIViewController) {
        viewController?.navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    func transitBack() {
        viewController?.dismiss(animated: true)
    }
}
