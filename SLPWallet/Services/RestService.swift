//
//  RestService.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Moya
import RxSwift

enum RestError: Error {
    case REST_UTXOS
}

class RestService {
    
    // Fetch UTXO
    static func fetchUTXOs(_ address: String) -> Single<[ResponseUTXO]> {
        return Single<[ResponseUTXO]>.create(subscribe: { (observer) -> Disposable in
            // Get a utxo
            //
            let bag = DisposeBag()
            let provider = MoyaProvider<RestNetwork>()
            provider.rx
                .request(.fetchUTXOs(address))
                .retry(3)
                .map([ResponseUTXO].self)
                .asObservable()
                .subscribe ({ (event) in
                    switch event {
                    case .next(let utxos):
                        observer(.success(utxos))
                    case .error(_):
                        observer(.error(RestError.REST_UTXOS))
                    default: break
                    }
                })
                .disposed(by: bag)
            return Disposables.create()
        })
    }
}
