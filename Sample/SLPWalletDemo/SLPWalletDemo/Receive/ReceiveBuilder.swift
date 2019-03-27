//
//  ReceiveBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class ReceiveBuilder {
    
    func provide() -> ReceiveViewController {
        let viewController = UIStoryboard(name: "Receive", bundle: nil).instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
        
        let presenter = ReceivePresenter()
        
        presenter.viewDelegate = viewController
        
        viewController.presenter = presenter
        
        return viewController
    }
}
