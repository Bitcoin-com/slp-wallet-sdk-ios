//
//  TokensRouter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class TokensRouter: BaseRouter {
    
    func transitToToken(_ token: SLPToken) {
        let tokenViewController = TokenBuilder().provide(token: token)
        viewController?.navigationController?.pushViewController(tokenViewController, animated: true)
    }
    
    func transitToToken(_ tokenViewController: TokenViewController) {
        viewController?.navigationController?.pushViewController(tokenViewController, animated: true)
    }
    
    func transitToReceive() {
        let receiveViewController = ReceiveBuilder().provide()
        viewController?.navigationController?.pushViewController(receiveViewController, animated: true)
    }
    
    func transitToSettings() {
        let settingsViewController = SettingsBuilder().provide()
        let navController = UINavigationController(rootViewController: settingsViewController)
        viewController?.present(navController, animated: true)
    }
}
