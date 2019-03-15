//
//  TokenViewCell.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/15.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import IGIdenticon

class TokenViewCell: UITableViewCell {
    
    var tokenOutput: TokenOutput? {
        didSet {
            guard let tokenOutput = self.tokenOutput else {
                return
            }
            
            titleLabel.text = tokenOutput.name
            subTitleLabel.text = tokenOutput.ticker
            
            let balance = NSDecimalNumber(value: tokenOutput.balance)
            let nf = NumberFormatter()
            nf.usesGroupingSeparator = true
            nf.numberStyle = .currency
            nf.maximumFractionDigits = tokenOutput.decimal
            nf.currencySymbol = "\(tokenOutput.ticker) "
            thirdTitleLabel.text = nf.string(from: balance)
            
            iconImageView.image = Identicon().icon(from: tokenOutput.id, size: CGSize(width: 48, height: 48))
            iconImageView.layer.cornerRadius = 24
            iconImageView.layer.borderColor = UIColor.white.cgColor
            iconImageView.layer.borderWidth = 1
            iconImageView.clipsToBounds = true
            iconImageView.backgroundColor = UIColor.white
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var thirdTitleLabel: UILabel!

}
