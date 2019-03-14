//
//  SendTokenInteractor.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import RxSwift

class SendTokenInteractor {
    
    fileprivate let bag = DisposeBag()
    
    func sendToken(_ tokenId: String, amount: Double, toAddress: String) -> Single<String> {
        return Single<String>.create { single in
            WalletManager.shared.wallet
                .sendToken(tokenId, amount: amount, toAddress: toAddress)
                .subscribe(onSuccess: { txid in
                    single(.success(txid))
                }, onError: { error in
                    single(.error(error))
                })
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
}
