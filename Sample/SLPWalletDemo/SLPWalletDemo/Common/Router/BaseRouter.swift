//
//  Router.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class BaseRouter {
    
    weak var viewController: UIViewController?
    
    init() {
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
