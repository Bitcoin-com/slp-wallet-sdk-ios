# SLPWallet iOS SDK

[![Build Status](https://travis-ci.com/bitcoin-portal/slp-wallet-sdk-ios.svg?token=PAo6Ye6VXq8pszqjtpHk&branch=master)](https://travis-ci.com/bitcoin-portal/slp-wallet-sdk-ios)

## Installation

### CocoaPods

#### Podfile

```ruby
platform :ios, '10.0'

target 'SLPWalletTestApp' do
use_frameworks!

# Pods for SLPWalletTestApp
pod 'SLPWallet', :git => 'https://github.com/bitcoin-portal/slp-wallet-sdk-ios.git', :branch => 'master'

end
```
#### Commands

```bash
$ brew install autoconf automake // Required with BitcoinKit
$ brew install libtool // Required with BitcoinKit
$ pod install
```

#### Pod install issue

```bash 
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/
```

## Get Started

### Creating new wallet with/without mnemonic

The wallet is working with only 1 address using the SLP recommanded path 44'/245'/0' + m/0/0.

```swift
// Init 1
// Generate/Restore a wallet + Save/Get in Keychain
// If mnemonic in Keychain
// Restore wallet
// else 
// Generate mnemonic
let wallet = try SLPWallet(.testnet) // .mainnet or .testnet

// Init 2
// Restore a wallet from Mnemonic + Save in Keychain
let wallet = try SLPWallet("My Mnemonic", network: .testnet) // .mainnet or .testnet

// Init 3
// Generate a wallet
// If force == true 
//  Generate everytime a new wallet
// else 
//  => Init 1
let wallet = try SLPWallet(.testnet, force: Bool)  // .mainnet or .testnet
```

### Addresses + tokens

```swift
wallet.mnemonic // [String]
wallet.slpAddress // String
wallet.cashAddress // String
wallet.tokens // [String:SLPToken] Tokens accessible if you fetch it already once or you started the scheduler
```
### Fetch my tokens

```swift
wallet
    .fetchTokens() // RxSwift => Single<[String:Token]>
    .subscribe(onSuccess: { tokens in
        // My tokens
        tokens.forEach({ tokenId, token in
            token.tokenId
            token.tokenName
            token.tokenTicker
            token.decimal
            token.getBalance()
            token.getGas()
        })
    }, onError: { error in
        // ...
    })
```
### Send token

```swift
wallet
    .sendToken(tokenId, amount: amount, toAddress: toAddress) // toAddress can be a slp / cash address or legacy
    .subscribe(onSuccess: { txid in // RxSwift => Single<String>
        // ...
    }, onError: { error in
        // ...
    })
```
### Auto update wallet/tokens (balances + gas)

```swift
// Start & stop
wallet.scheduler.resume()
wallet.scheduler.suspend()

// Change the interval
wallet.schedulerInterval = 10 // in seconds
```
### WalletDelegate called when the scheduler is started

```swift
class MyViewController: SLPWalletDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wallet = ... // Setup a wallet
        wallet.delegate = self
    }

    func onUpdatedToken(_ tokens: [String:SLPToken]) {
        // My updated tokens
        tokens.forEach({ tokenId, token in
            token.tokenId
            token.tokenName
            token.tokenTicker
            token.decimal
            token.getBalance()
            token.getGas()
        })
    }
}
```

## Authors & Maintainers
- [jbdtky](https://github.com/jbdtky)
- [holemcross](https://github.com/holemcross)

## References
- [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
- [Simple Ledger Protocol (SLP)](https://github.com/simpleledger/slp-specifications/blob/master/slp-token-type-1.md)

## License

SLPWallet iOS SDK is available under the MIT license. See the LICENSE file for more info.
