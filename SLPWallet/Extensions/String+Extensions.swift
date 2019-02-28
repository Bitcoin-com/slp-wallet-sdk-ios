//
//  String+Extensions.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/02/28.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//


extension String {
    func toSatoshis() -> Int {
        return Double(self)?.toSatoshis() ?? 0
    }
}
