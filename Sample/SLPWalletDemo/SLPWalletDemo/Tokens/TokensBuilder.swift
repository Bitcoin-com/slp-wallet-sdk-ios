//
//  TokensBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class TokensBuilder {
    
    func provide() -> TokensViewController {
        let viewController = UIStoryboard(name: "Tokens", bundle: nil).instantiateViewController(withIdentifier: "TokensViewController") as! TokensViewController
        
        let router = TokensRouter(viewController: viewController)
        let presenter = TokensPresenter()
        let interactor = FetchTokensInteractor()
        
        presenter.router = router
        presenter.fetchTokensInteractor = interactor
        presenter.viewDelegate = viewController
        
        viewController.presenter = presenter
        
        return viewController
    }
}
