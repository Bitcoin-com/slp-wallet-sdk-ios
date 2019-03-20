//
//  TokensInterfaceController.swift
//  DemoSLPWallet Watch Extension
//
//  Copyright © 2019 Jean-Baptiste Dominguez
//  Copyright © 2019 Bitcoin.com
//

import WatchKit
import Foundation
import WatchConnectivity

class TokenRowController: NSObject {
    @IBOutlet var tokenNameLabel: WKInterfaceLabel!
    @IBOutlet var balanceLabel: WKInterfaceLabel!
}

class TokensInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var tokensTable: WKInterfaceTable!
    var tokens: [[String : String]] = [] {
        didSet {
            for index in 0..<tokensTable.numberOfRows {
                guard let controller = tokensTable.rowController(at: index) as? TokenRowController, let tokenName = tokens[index]["name"], let balance = tokens[index]["balance"] else {
                    continue
                }
                
                controller.tokenNameLabel.setText(tokenName)
                controller.balanceLabel.setText(balance)
            }
        }
    }
    var wallet: [String:String] = [:]
    
    let session = WCSession.default
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("SLP Wallet")
        processApplicationContext()
        session.delegate = self
        session.activate()
    }
    
    func processApplicationContext() {
        let data = session.receivedApplicationContext
        
        if let tokens = data["tokens"] as? [[String: String]] {
            tokensTable.setNumberOfRows(tokens.count, withRowType: "TokenRow")
            self.tokens = tokens
        }
        
        if let wallet = data["wallet"] as? [String: String] {
            self.wallet = wallet
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let token = tokens[rowIndex]
        presentController(withName: "TokenInterfaceController", context: token)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

}
