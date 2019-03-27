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
    
    func viewWillAppear() {
        if (wallet.cashAddress != WalletManager.shared.wallet.cashAddress) {
            viewDelegate?.navigationController?.setViewControllers([TokensBuilder().provide()], animated: true)
        }
    }
    
    func viewDidLoad() {
        // Fetch token on the viewLoad to setup the view
        fetchTokens()
        
        // Observe tokens
        WalletManager.shared
            .observeTokens()
            .subscribe({ [weak self] event in
                
                guard let strongSelf = self else {
                    return
                }
                
                if let token = event.element,
                    let _ = token.tokenTicker {
                    guard let tokenId = token.tokenId
                        , let tokenName = token.tokenName
                        , let tokenTicker = token.tokenTicker
                        , let tokenDecimal = token.decimal else {
                            return
                    }
                    
                    let tokenOutput = TokenOutput(id: tokenId, name: tokenName, ticker: tokenTicker, balance: token.getBalance().toCurrency(ticker: tokenTicker, decimal: tokenDecimal), decimal: tokenDecimal)
                    strongSelf.viewDelegate?.onGetToken(tokenOutput: tokenOutput)
                    
                    let gas = TokenOutput(id: "BCH", name: "Bitcoin Cash", ticker: "Satoshis", balance: Double(strongSelf.wallet.getGas()).toCurrency(ticker: "Satoshis", decimal: 0), decimal: 0)
                    strongSelf.viewDelegate?.onGetToken(tokenOutput: gas)
                    
                    if let _ = strongSelf.tokens?[tokenId] {
                        return
                    }
                    
                    // New token, so add it
                    strongSelf.tokens?[tokenId] = token
                }
            })
            .disposed(by: bag)
        
        // Notify the addresses
        viewDelegate?.onGetAddresses(slpAddress: wallet.slpAddress, cashAddress: wallet.cashAddress)
    }
    
    func fetchTokens() {
        
        fetchTokensInteractor?.fetchTokens()
            .subscribe(onSuccess: { [weak self] tokens in
                
                guard let strongSelf = self else {
                    return
                }
                
                // Store my tokens to take action on it later
                strongSelf.tokens = tokens
                
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
                
                let gas = TokenOutput(id: "BCH", name: "Bitcoin Cash", ticker: "Satoshis", balance: Double(strongSelf.wallet.getGas()).toCurrency(ticker: "Satoshis", decimal: 0), decimal: 0)
                
                tokenOutputs.insert(gas, at: 0)
                
                // Notify my UI
                strongSelf.viewDelegate?.onFetchTokens(tokenOutputs: tokenOutputs)
            }, onError: { [weak self] error in
                self?.viewDelegate?.onError()
            })
            .disposed(by: bag)
    }
    
    func didPreview(_ tokenId: String) -> UIViewController? {
        guard let tokens = self.tokens
            , let token = tokens[tokenId] else {
                return nil
        }
        
        // If token exists transit to the token module
        return TokenBuilder().provide(token: token)
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
        router?.transitToSettings()
    }
}
