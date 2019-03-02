# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'SLPWallet' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for SLPWallet
    pod 'BitcoinKit', :git => 'https://github.com/Bitcoin-com/BitcoinKit.git', :branch => 'master'
    pod 'RxSwift',      '~> 4.0'
    pod 'RxCocoa',      '~> 4.0'
    pod 'Moya/RxSwift', '~> 11.0'

    target 'SLPWalletTests' do
        inherit! :search_paths
        # Pods for testing
	    pod 'RxBlocking'
        pod 'RxTest'
        pod 'Quick'
        pod 'Nimble'
    end
end
