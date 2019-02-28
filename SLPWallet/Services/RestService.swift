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
    static let bag = DisposeBag()
    
    enum RestError: Error {
        case REST_UTXOS
        case REST_TX_DETAILS
    }
}

// Fetch UTXOs
//
extension RestService {
    
    public struct ResponseUTXOs: Codable {
        public let utxos: [ResponseUTXO]
        public let scriptPubKey: String
    }
    
    public struct ResponseUTXO: Codable {
        public let txid: String
        public let vout: Int
        public let satoshis: Int
        public let confirmations: Int
    }
    
    static public func fetchUTXOs(_ address: String) -> Single<ResponseUTXOs> {
        
        return Single<ResponseUTXOs>.create(subscribe: { (observer) -> Disposable in
            // Get a utxo
            //
            let provider = MoyaProvider<RestNetwork>()
            provider.rx
                .request(.fetchUTXOs(address))
                .retry(3)
                .map(ResponseUTXOs.self)
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
                .disposed(by: RestService.bag)
            return Disposables.create()
        })
    }
}

// Fetch TxDetails
//
extension RestService {
    
    public struct ResponseTx: Codable {
        public let txid: String
        public let vin: [ResponseInput]
        public let vout: [ResponseOutput]
        public let confirmations: Int
        public let time: Int
        public let fees: Double
        
        public struct ResponseInput: Codable {
            public let cashAddress: String
            public let value: Int
        }
        
        public struct ResponseOutput: Codable {
            public let value: String
            public let n: Int
            public let scriptPubKey: ResponseScriptPubKey
        }
        
        public struct ResponseScriptPubKey: Codable {
            public let addresses: [String]?
            public let hex: String
            public let asm: String
        }
    }
    
    public static func fetchTxDetails(_ txids: [String]) -> Single<[ResponseTx]> {
        return Single<[ResponseTx]>.create(subscribe: { (observer) -> Disposable in
            // Get tx details
            //
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
                .disposed(by: RestService.bag)
            return Disposables.create()
        })
    }
}
