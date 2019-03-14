//
//  WalletManager.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import SLPWallet
import RxSwift
import RxCocoa

enum WalletManagerError: Error {
    case TOKEN_NOT_FOUND
}

class WalletManager: SLPWalletDelegate {
    
    static let shared = WalletManager()
    
    var wallet: SLPWallet
    
    var observedToken: BehaviorRelay<SLPToken>?
    var observedTokens: PublishSubject<SLPToken>?
    
    init() {
        do {
            wallet = try SLPWallet(.mainnet)
            wallet.delegate = self
            wallet.scheduler.resume()
        } catch {
            fatalError("It should be able to construct a wallet")
        }
    }
    
    func observeToken(tokenId: String) throws -> Observable<SLPToken> {
        guard let token = wallet.tokens[tokenId] else {
            throw WalletManagerError.TOKEN_NOT_FOUND
        }
        
        let observedToken = BehaviorRelay<SLPToken>(value: token)
        self.observedToken = observedToken
        
        return observedToken.asObservable()
    }
    
    func observeTokens() -> Observable<SLPToken> {
        guard let observedTokens = self.observedTokens else {
            let observedTokens = PublishSubject<SLPToken>()
            self.observedTokens = observedTokens
            
            return observedTokens.asObservable()
        }
        
        return observedTokens.asObservable()
    }
    
    func onUpdatedToken(_ token: SLPToken) {
        
        // Notify
        if let observedToken = self.observedToken
            , observedToken.value.tokenId == token.tokenId {
            observedToken.accept(token)
        }
        
        // Notify
        if let observedTokens = self.observedTokens {
            observedTokens.onNext(token)
        }
        
    }
}
