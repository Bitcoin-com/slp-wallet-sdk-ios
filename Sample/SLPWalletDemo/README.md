# SLPWallet Demo

![Version](https://img.shields.io/badge/version-v0.2.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg) 
![Compatibility](https://img.shields.io/badge/iOS-%3E=10.0-orange.svg) 
![License](https://img.shields.io/badge/License-MIT-black.svg) 

## Get Started

### Playing with the SDK

This code comes from [WalletManager.swift](SLPWalletDemo/Common/Manager/WalletManager.swift). You can create a SLP wallet in few lines only. All other files don't concern the SDK but mainly UI.

```swift
class WalletManager: SLPWalletDelegate {
    
    static let shared = WalletManager()
    
    var wallet: SLPWallet
    
    var observedToken: BehaviorRelay<SLPToken>?
    var observedTokens: PublishSubject<SLPToken>?
    
    init() {
        do {
            wallet = try SLPWallet(.mainnet) // 1 line 🚀🚀🚀
            wallet.delegate = self
            wallet.scheduler.resume()
        } catch {
            fatalError("It should be able to construct a wallet")
        }
    }

    //
    // ... 
    //
    
    // Call with SLPWalletDelegate ❗️💥🚀
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

```

Then it shows how to send token in this file [SendTokenInteractor.swift](SLPWalletDemo/Common/Interactor/SendTokenInteractor.swift) 
```Swift
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

```

## Demo

![Alt Text](demo-app.gif)

## Authors & Maintainers
- Jean-Baptiste Dominguez [[Github](https://github.com/jbdtky), [Twitter](https://twitter.com/jbdtky)]

## License

SLPWalletDemo is available under the MIT license. See the LICENSE file for more info.