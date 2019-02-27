//
//  RestService.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Moya
import RxSwift

public class RestService {
    
    enum RestError: Error {
        case REST_UTXOS
        case REST_TX_DETAILS
    }
    
    // Fetch UTXO
    static public func fetchUTXOs(_ address: String) -> Single<[ResponseUTXO]> {
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
                        print("fetchUTXOs:Success")
                        observer(.success(utxos))
                    case .error(let error):
                        print("fetchUTXOs:Error")
                        print(error)
                        observer(.error(RestError.REST_UTXOS))
                    default: break
                    }
                })
                .disposed(by: bag)
            return Disposables.create()
        })
    }
    
    // Fetch UTXO
    static func fetchTxDetails(_ txids: String) -> Single<[ResponseTx]> {
        return Single<[ResponseTx]>.create(subscribe: { (observer) -> Disposable in
            // Get tx details
            //
            let bag = DisposeBag()
            let provider = MoyaProvider<RestNetwork>()
            provider.rx
                .request(.fetchTxDetails(txids))
                .retry(3)
                .map([ResponseTx].self)
                .asObservable()
                .subscribe ({ (event) in
                    switch event {
                    case .next(let txs):
                        observer(.success(txs))
                    case .error(let error):
                        print(error)
                        observer(.error(RestError.REST_TX_DETAILS))
                    default: break
                    }
                })
                .disposed(by: bag)
            return Disposables.create()
        })
    }
}
