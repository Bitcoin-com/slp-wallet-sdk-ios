//
//  RestoreBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import SLPWallet

class RestoreBuilder: BaseBuilder {
    
    func provide() -> UIViewController {
        let viewController = UIStoryboard(name: "Restore", bundle: nil).instantiateViewController(withIdentifier: "RestoreViewController") as! RestoreViewController
        
        let presenter = RestorePresenter()
        let interactor = RestoreWalletInteractor()
        let router = RestoreRouter(viewController: viewController)
        
        presenter.router = router
        presenter.viewDelegate = viewController
        presenter.restoreWalletInteractor = interactor
        
        viewController.presenter = presenter
        
        return viewController
    }
}
