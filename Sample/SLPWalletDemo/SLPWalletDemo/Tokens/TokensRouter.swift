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
    
    func transitToToken(token: SLPToken) {
        let tokenViewController = TokenBuilder.provide(token: token)
        viewController?.navigationController?.pushViewController(tokenViewController, animated: true)
    }
    
    func transitToReceive() {
        let receiveViewController = ReceiveBuilder.provide()
        viewController?.navigationController?.pushViewController(receiveViewController, animated: true)
    }
    
    func transitToMnemonic() {
        let mnemonicViewController = MnemonicBuilder.provide()
        viewController?.navigationController?.pushViewController(mnemonicViewController, animated: true)
    }
}
