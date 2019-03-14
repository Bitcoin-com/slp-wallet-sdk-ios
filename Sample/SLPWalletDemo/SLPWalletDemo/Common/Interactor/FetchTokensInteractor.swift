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
                    let token1 = SLPToken("test1")
                    token1.tokenName = "Test 1"
                    token1.tokenTicker = "TE1"
                    
                    let token2 = SLPToken("test2")
                    token2.tokenName = "Test 2"
                    token2.tokenTicker = "TE2"
                    
                    let token3 = SLPToken("test3")
                    token3.tokenName = "Test 3"
                    token3.tokenTicker = "TE3"
                    
                    let tokens = ["test1": token1, "test2": token2, "test3": token3]
                    
                    single(.success(tokens))
                })
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
}
