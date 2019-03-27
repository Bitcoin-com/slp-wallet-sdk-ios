//
//  SettingsPresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class SettingsPresenter {
    
    weak var viewDelegate: SettingsViewController?
    var router: SettingsRouter?
    
    var settings: [SettingsEntity]
    
    init(_ settings: [SettingsEntity]) {
        self.settings = settings
    }
    
    func viewDidLoad() {
        viewDelegate?.onPresenterDidLoad(settings)
    }
    
    func didPushClose() {
        router?.transitBack()
    }
    
    func didPushSetting(_ i: Int) {
        router?.transitTo(settings[i].builder)
    }
    
    func didPreview(_ i: Int) -> UIViewController? {
        let builder = settings[i].builder
        return builder.provide()
    }
    
    func didPushPreview(_ viewControllerToCommit: UIViewController) {
        router?.transitTo(viewControllerToCommit)
    }
}
