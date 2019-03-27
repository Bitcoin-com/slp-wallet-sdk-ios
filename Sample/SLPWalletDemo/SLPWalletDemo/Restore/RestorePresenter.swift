//
//  RestorePresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class RestorePresenter {
    
    weak var viewDelegate: RestoreViewController?
    var restoreWalletInteractor: RestoreWalletInteractor?
    var router: RestoreRouter?
    
    fileprivate var mnemonic: String?
    
    init() {}
    
    func didPushRestore(_ mnemonic: String) {
        let words = mnemonic.components(separatedBy: " ")
        
        guard let restoreWalletInteractor = self.restoreWalletInteractor
            , words.count == 12 else {
            viewDelegate?.onError()
            return
        }
        
        if restoreWalletInteractor.restore(mnemonic) {
            viewDelegate?.onSuccess()
        } else {
            viewDelegate?.onError()
        }
    }
    
    func didSuccess() {
        router?.transitBack()
    }
}
