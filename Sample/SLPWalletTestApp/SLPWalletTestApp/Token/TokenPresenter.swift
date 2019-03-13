//
//  TokenPresenter.swift
//  SLPWalletTestApp
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import SLPWallet
import RxSwift

struct TokenPresenterOutput {
    var tokenOutput: TokenOutput
    var slpAddress: String
    var cashAddress: String
}

enum TokenPresenterError: Error {
    case INVALID_INPUTS
}

class TokenPresenter {
    
    fileprivate let bag = DisposeBag()
    fileprivate var wallet: SLPWallet
    
    var token: SLPToken?
    var sendTokenInteractor: SendTokenInteractor?
    weak var viewDelegate: TokenViewController?
    
    init() {
        wallet = WalletManager.shared.wallet
    }
    
    func viewDidLoad() {
        guard let token = self.token
            , let tokenId = token.tokenId
            , let tokenName = token.tokenName
            , let tokenTicker = token.tokenTicker else {
            return
        }
        
        let slpAddress = WalletManager.shared.wallet.slpAddress
        let cashAddress = WalletManager.shared.wallet.cashAddress
        
        let tokenOutput = TokenOutput(id: tokenId, name: tokenName, ticker: tokenTicker, balance: token.getBalance())
        
        let output = TokenPresenterOutput(tokenOutput: tokenOutput, slpAddress: slpAddress, cashAddress: cashAddress)
        
        viewDelegate?.onViewDidLoad(output)
        
        do {
            let observable = try WalletManager.shared.observeToken(tokenId: tokenId)
            observable.subscribe({ event in
                if let token = event.element,
                    let tokenTicker = token.tokenTicker {
                    self.viewDelegate?.onGetBalance(token.getBalance(), ticker: tokenTicker)
                }
            })
            .disposed(by: bag)
        } catch {
            // Cannot listen this token
        }
    }
    
    func didPushSend() {
        viewDelegate?.presentAmount()
    }
    
    func didPushSend(_ amount: String, toAddress: String) {
        
        guard let tokenId = token?.tokenId
            , let amount = Double(amount) else {
            self.viewDelegate?.onError(TokenPresenterError.INVALID_INPUTS)
            return
        }
        
        sendTokenInteractor?
            .sendToken(tokenId, amount: amount, toAddress: toAddress)
            .subscribe(onSuccess: { txid in
                // TODO: On success
                self.viewDelegate?.onSuccessSend(txid)
            }, onError: { error in
                // TODO: On error
                self.viewDelegate?.onError(error)
            })
            .disposed(by: bag)
    }
}
