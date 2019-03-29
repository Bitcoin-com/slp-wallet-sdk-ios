//
//  Network.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Moya

enum RestNetwork {
    case fetchUTXOs([String])
    case fetchTxDetails([String])
    case fetchTxValidations([String])
    case broadcast(String)
}

extension RestNetwork: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: SLPWalletConfig.shared.restURL) else {
            fatalError("should be able to parse this URL")
        }
        
        return url
    }
    
    public var path: String {
        switch self {
        case .fetchUTXOs:
            return "/address/utxo"
        case .fetchTxDetails:
            return "/transaction/details"
        case .fetchTxValidations:
            return "/slp/validateTxid"
        case .broadcast(let rawTx):
            return "/rawtransactions/sendRawTransaction/\(rawTx)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .fetchUTXOs: return .post
        case .fetchTxDetails: return .post
        case .fetchTxValidations: return .post
        case .broadcast: return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .fetchUTXOs(let addresses):
            return .requestParameters(parameters: ["addresses": addresses], encoding: JSONEncoding.default)
        case .fetchTxDetails(let txids):
            return .requestParameters(parameters: ["txids": txids], encoding: JSONEncoding.default)
        case .fetchTxValidations(let txids):
            return .requestParameters(parameters: ["txids": txids], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        var headers =  ["Content-Type": "application/json"]
        
        guard let apiKey = SLPWalletConfig.shared.restAPIKey else {
            return headers
        }
        
        // Add the API Key
        headers["Authorization"] = "Basic \(apiKey)"
        
        return headers
    }
}
