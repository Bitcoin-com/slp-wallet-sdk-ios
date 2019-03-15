//
//  ReceivePresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

struct AddressOutput {
    var slpAddress: String
    var cashAddress: String
}

class ReceivePresenter {
    weak var viewDelegate: ReceiveViewController?
    
    fileprivate var slpAddress: String
    fileprivate var cashAddress: String
    fileprivate var selectedAddress: String
    
    init() {
        slpAddress = WalletManager.shared.wallet.slpAddress
        cashAddress = WalletManager.shared.wallet.cashAddress
        selectedAddress = slpAddress
    }
    
    func viewDidLoad() {
        let output = AddressOutput(slpAddress: slpAddress, cashAddress: cashAddress)
        
        viewDelegate?.onViewDidLoad(output)
    }
    
    func didSelectType(index: Int) {
        switch index {
        case 0:
            selectedAddress = slpAddress
        default:
            selectedAddress = cashAddress
        }
        viewDelegate?.onSelectAddress(selectedAddress)
    }
    
    func didPushCopy() {
        UIPasteboard.general.string = selectedAddress
    }
}
