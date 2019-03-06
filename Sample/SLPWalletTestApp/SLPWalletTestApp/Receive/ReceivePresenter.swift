//
//  ReceivePresenter.swift
//  SLPWalletTestApp
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation

struct AddressOutput {
    var slpAddress: String
    var cashAddress: String
}

class ReceivePresenter {
    weak var viewDelegate: ReceiveViewController?
    
    fileprivate var slpAddress: String
    fileprivate var cashAddress: String
    
    init() {
        slpAddress = WalletManager.shared.wallet.slpAddress
        cashAddress = WalletManager.shared.wallet.cashAddress
    }
    
    func viewDidLoad() {
        let output = AddressOutput(slpAddress: slpAddress, cashAddress: cashAddress)
        
        viewDelegate?.onViewDidLoad(output)
    }
    
    func didSelectType(index: Int) {
        switch index {
        case 0:
            viewDelegate?.onSelectAddress(slpAddress)
        default:
            viewDelegate?.onSelectAddress(cashAddress)
        }
    }
}
