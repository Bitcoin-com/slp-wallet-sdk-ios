//
//  FetchTokensInteractor.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import RxSwift
import SLPWallet

class FetchTokensInteractor {
    
    fileprivate let bag = DisposeBag()
    
    func fetchTokens() -> Single<[String:SLPToken]> {
        return Single<[String:SLPToken]>.create { single in
            
            WalletManager.shared.wallet
                .fetchTokens()
                .retry(3)
                .subscribe(onSuccess: { tokens in
                    single(.success(tokens))
                }, onError: { error in
                    single(.error(error))
                })
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
}
