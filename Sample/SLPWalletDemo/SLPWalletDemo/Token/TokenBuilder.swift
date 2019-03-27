//
//  TokenBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class TokenBuilder {
    
    func provide(token: SLPToken) -> TokenViewController {
        let viewController = UIStoryboard(name: "Token", bundle: nil).instantiateViewController(withIdentifier: "TokenViewController") as! TokenViewController
        
        let presenter = TokenPresenter()
        let sendTokenInteractor = SendTokenInteractor()
        let router = TokenRouter(viewController: viewController)
        
        presenter.viewDelegate = viewController
        presenter.sendTokenInteractor = sendTokenInteractor
        presenter.token = token
        presenter.router = router

        viewController.presenter = presenter
        
        return viewController
    }
}
