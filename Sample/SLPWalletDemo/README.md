![Logo](../../github_logo.png)

# SLPWallet Demo :snake: (Built with VIPER)

![Version](https://img.shields.io/badge/version-v0.4.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-ios-black.svg) 
![Compatibility](https://img.shields.io/badge/iOS-+10.0-orange.svg) 
![Compatibility](https://img.shields.io/badge/Swift-4.0-orange.svg) 
![License](https://img.shields.io/badge/License-MIT-black.svg) 

## Get Started

### Playing with the SDK

You can create an SLP wallet in a few lines only. This code comes from [WalletManager.swift](SLPWalletDemo/Common/Manager/WalletManager.swift). All other files are UI related code and don't concern the SDK. 

```swift
//
// ...
//

import SLPWallet

//
// ...
//

class WalletManager {
    
    static let shared = WalletManager()
    
    var wallet: SLPWallet
    
    var observedToken: BehaviorRelay<SLPToken>?
    var observedTokens: PublishSubject<SLPToken>?
    
    init() {
        do {
            wallet = try SLPWallet(.mainnet)
            setup()
        } catch {
            fatalError("It should be able to construct a wallet")
        }
    }

    //
    // ... 
    //
}

extension WalletManager: SLPWalletDelegate {
    
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

After creating your wallet, you can start sending tokens. This file describes how to send tokens: [SendTokenInteractor.swift](SLPWalletDemo/Common/Interactor/SendTokenInteractor.swift). Below you can see a preview of the file.
```Swift
//
// ...
//

class SendTokenInteractor {
    
    fileprivate let bag = DisposeBag()
    
    func sendToken(_ tokenId: String, amount: Double, toAddress: String) -> Single<String> {
        return Single<String>.create { single in
            WalletManager.shared.wallet
                .sendToken(tokenId, amount: amount, toAddress: toAddress) // That's it 💥🚀
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
