//
//  InterfaceController.swift
//  TokenInterfaceController.swift
//  DemoSLPWallet Watch Extension
//
//  Copyright © 2019 Jean-Baptiste Dominguez
//  Copyright © 2019 Bitcoin.com

import WatchKit
import WatchConnectivity
import Foundation

class TokenInterfaceController: WKInterfaceController {
    
    @IBOutlet var QRCodeImage: WKInterfaceImage!
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var balanceLabel: WKInterfaceLabel!
    
    var tokenId: String?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let token = context as? [String: String]
            , let tokenId = token["id"]
            , let tokenName = token["name"]
            , let balance = token["balance"] else {
            return
        }
        
        self.tokenId = tokenId
        
        nameLabel.setText(tokenName)
        balanceLabel.setText(balance)
        
        setTitle(tokenId)
    }
    
    
    @IBAction func didPushSend() {
        dismiss()
    }
}
