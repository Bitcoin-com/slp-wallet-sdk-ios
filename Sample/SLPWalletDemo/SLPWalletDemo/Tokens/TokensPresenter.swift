//
//  TokensPresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import RxSwift
import SLPWallet

struct TokenOutput {
    var id: String
    var name: String
    var ticker: String
    var balance: String
    var decimal: Int
}

extension TokenOutput: Equatable {
    public static func == (lhs: TokenOutput, rhs: TokenOutput) -> Bool {
        return lhs.id == rhs.id
    }
}

class TokensPresenter {
    
    fileprivate var wallet: SLPWallet
    fileprivate var tokens: [String:SLPToken]?
    
    var fetchTokensInteractor: FetchTokensInteractor?
    var router: TokensRouter?
    weak var viewDelegate: TokensViewController?
    
    let bag = DisposeBag()
    
    init() {
        wallet = WalletManager.shared.wallet
    }
    
    func viewDidLoad() {
        // Fetch token on the viewLoad to setup the view
        fetchTokens()
        
        // Notify the addresses
        viewDelegate?.onGetAddresses(slpAddress: wallet.slpAddress, cashAddress: wallet.cashAddress)
    }
    
    func fetchTokens() {
        
        WalletManager.shared
            .observeTokens()
            .subscribe({ event in
                if let token = event.element,
                    let _ = token.tokenTicker {
                    guard let tokenId = token.tokenId
                        , let tokenName = token.tokenName
                        , let tokenTicker = token.tokenTicker
                        , let tokenDecimal = token.decimal else {
                            return
                    }
                    
                    let tokenOutput = TokenOutput(id: tokenId, name: tokenName, ticker: tokenTicker, balance: token.getBalance().toCurrency(ticker: tokenTicker, decimal: tokenDecimal), decimal: tokenDecimal)
                    self.viewDelegate?.onGetToken(tokenOutput: tokenOutput)
                    
                    let gas = TokenOutput(id: "BCH", name: "Bitcoin Cash", ticker: "Satoshis", balance: Double(self.wallet.getGas()).toCurrency(ticker: "Satoshis", decimal: 0), decimal: 0)
                    self.viewDelegate?.onGetToken(tokenOutput: gas)
                }
            })
            .disposed(by: bag)
        
        fetchTokensInteractor?.fetchTokens()
            .subscribe(onSuccess: { tokens in
                
                // Store my tokens to take action on it later
                self.tokens = tokens
                
                // Prepare the output for my view
                var tokenOutputs = tokens
                    .compactMap({ (key, value) -> TokenOutput? in
                        guard let tokenId = value.tokenId
                            , let tokenName = value.tokenName
                            , let tokenTicker = value.tokenTicker
                            , let tokenDecimal = value.decimal else {
                                return nil
                        }
                                                
                        return TokenOutput(id: tokenId, name: tokenName, ticker: tokenTicker, balance: value.getBalance().toCurrency(ticker: tokenTicker, decimal: tokenDecimal), decimal: tokenDecimal)
                    })
                
                let gas = TokenOutput(id: "BCH", name: "Bitcoin Cash", ticker: "Satoshis", balance: Double(self.wallet.getGas()).toCurrency(ticker: "Satoshis", decimal: 0), decimal: 0)
                
                tokenOutputs.insert(gas, at: 0)
                
                // Notify my UI
                self.viewDelegate?.onFetchTokens(tokenOutputs: tokenOutputs)
            }, onError: { error in
                // TODO: Do something
            })
            .disposed(by: bag)
    }
    
    func didPreview(_ tokenId: String) -> UIViewController? {
        guard let tokens = self.tokens
            , let token = tokens[tokenId] else {
                return nil
        }
        
        // If token exists transit to the token module
        return TokenBuilder.provide(token: token)
    }
    
    func didPushPreview(_ viewControllerToCommit: UIViewController) {
        guard let tokenViewController = viewControllerToCommit as? TokenViewController else {
            return
        }
        
        // If token exists transit to the token module
        router?.transitToToken(tokenViewController)
    }
    
    func didPushToken(_ tokenId: String) {
        guard let tokens = self.tokens
            , let token = tokens[tokenId] else {
                return
        }
        
        // If token exists transit to the token module
        router?.transitToToken(token)
    }
    
    func didRefreshTokens() {
        fetchTokens()
    }
    
    func didPushReceive() {
        // Transit the receive module
        router?.transitToReceive()
    }
    
    func didPushMnemonic() {
        // Transit the receive module
        router?.transitToMnemonic()
    }
}
