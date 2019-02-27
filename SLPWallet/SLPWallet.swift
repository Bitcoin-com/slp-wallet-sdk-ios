//
//  SLPWallet.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/27.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import BitcoinKit

public class SLPWallet {
    
    fileprivate let privKey: PrivateKey
    fileprivate let network: Network
    
    public let cashAddress: String
    public let slpAddress: String
    
    init(_ mnemonic: String, network: Network) {
        let seed = Mnemonic.seed(mnemonic: mnemonic.components(separatedBy: ","))
        let hdPrivKey = HDPrivateKey(seed: seed, network: network)
        
        let xPrivKey = try! hdPrivKey.derived(at: 44, hardened: true).derived(at: 0).derived(at: 0)
        let privKey = try! xPrivKey.derived(at: UInt32(0)).derived(at: UInt32(0)).privateKey()
        
        self.privKey = privKey
        self.network = network
        self.cashAddress = privKey.publicKey().toCashaddr().cashaddr
        
        let addressData: Data = [0] + privKey.publicKey().toCashaddr().data
        
        // Quick way to do it, @angel is working on building it in BitcoinKit
        self.slpAddress = Bech32.encode(addressData, prefix: network == .mainnet ? "simpleledger" : "slptest")
    }
}
