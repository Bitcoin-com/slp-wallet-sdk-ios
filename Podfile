source 'https://github.com/Bitcoin-com/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'SLPWallet' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for SLPWallet
    pod 'RxSwift',          '~> 4.0'
    pod 'RxCocoa',          '~> 4.0'
    pod 'Moya/RxSwift',     '~> 11.0'
    pod 'KeychainAccess',   '~> 3.1.2'
    pod 'BitcoinKit',       '~> 1.1.0'

    target 'SLPWalletTests' do
        inherit! :search_paths

        # Pods for SLPWalletTests
        pod 'RxBlocking'
        pod 'RxTest'
        pod 'Quick'
        pod 'Nimble'
    end
end
