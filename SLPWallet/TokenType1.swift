//
//  TokenType1.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import RxSwift
import BitcoinKit
import Moya

class TokenType1 {
}

// External API
//
extension TokenType1 {
    
    public static func create(_ name: String, symbol: String, quantity: Int, fundingWif: String, fundingAddress: String) -> Single<String> {
        return Single<String>.create(subscribe: { (observer) -> Disposable in
            
            let bag = DisposeBag()
            
            // Fetch UTXOs
            RestService.fetchUTXOs(fundingAddress)
                .subscribe(onSuccess: { utxos in
                    
                    // Take the first UTXO to generate the Genesis
                    // ...
                    
                }, onError: { _ in
 
                })
                .disposed(by: bag)
            
            
            return Disposables.create()
        })
    }
    
    public static func send(_ name: String, symbol: String, quantity: Int, fundingWif: String, fundingAddress: String) -> Single<String> {
        return Single<String>.create(subscribe: { (observer) -> Disposable in
            
            let bag = DisposeBag()
            
            RestService.fetchUTXOs(fundingAddress)
                .subscribe(onSuccess: { utxos in
                    
                    // Check output return
                    // ...
                    
                }, onError: { _ in
                    
                })
                .disposed(by: bag)
            
            return Disposables.create()
        })
    }
}
