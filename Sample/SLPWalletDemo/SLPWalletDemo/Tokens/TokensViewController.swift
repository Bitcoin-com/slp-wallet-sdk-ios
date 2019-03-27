//
//  TokensViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import Lottie
import WatchConnectivity

class TokensViewController: UITableViewController {

    var tokenOutputs: [TokenOutput] = []
    var presenter: TokensPresenter?
    var animationView: LOTAnimationView?
    var session: WCSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SLP Token Wallet"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "qrcode_icon"), style: .plain, target: self, action: #selector(didPushReceive))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings_icon"), style: .plain, target: self, action: #selector(didPushMnemonic))
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshTokens), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TokenViewCell", bundle: nil), forCellReuseIdentifier: "TokenViewCell")
        
        // Custom refresh control
        let animationView = LOTAnimationView(name: "refresh_loading_animation")
        animationView.loopAnimation = true
        animationView.frame = refreshControl.bounds
        
        self.animationView = animationView
        
        refreshControl.tintColor = .clear
        refreshControl.addSubview(animationView)
        
        // 3D touch enable if available
        if(traitCollection.forceTouchCapability == .available){
            self.registerForPreviewing(with: self, sourceView: self.view)
        }
        
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        // Notify our presenter that we loaded the view
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.viewWillAppear()
    }
    
    @objc func didRefreshTokens() {
        // Activate the animation
        animationView?.play()
        
        // Refresh tokens
        presenter?.didRefreshTokens()
    }
    
    @objc func didPushReceive() {
        presenter?.didPushReceive()
    }
    
    @objc func didPushMnemonic() {
        presenter?.didPushMnemonic()
    }
    
    func onError() {
        refreshControl?.endRefreshing()
        animationView?.stop()
    }
    
    func onFetchTokens(tokenOutputs: [TokenOutput]) {
        // Reload the table on fetched tokens
        self.tokenOutputs = tokenOutputs
        tableView.reloadData()
        refreshControl?.endRefreshing()
        animationView?.stop()
        
        if let session = self.session {
            var data = [String: Any]()
            var tokens = [[String:String]]()
            tokenOutputs.forEach { (tokenOutput) in
                var token = [String: String]()
                token["id"] = tokenOutput.id
                token["name"] = tokenOutput.name
                token["balance"] = tokenOutput.balance
                tokens.append(token)
            }
            
            data["tokens"] = tokens
            
            do { // Try to update the WatchApp
                try session.updateApplicationContext(data)
            } catch {}
        }
    }
    
    func onGetAddresses(slpAddress: String, cashAddress: String) {
        if let session = self.session {
            var data = [String: Any]()
            data["slpAddress"] = slpAddress
            data["cashAddress"] = cashAddress
            
            do { // Try to update the WatchApp
//                try session.updateApplicationContext(data)
            } catch {}
        }
    }
    
    func onGetToken(tokenOutput: TokenOutput) {
        // Reload the table on fetched tokens
        if let index = self.tokenOutputs.firstIndex(of: tokenOutput) {
            self.tokenOutputs[index] = tokenOutput
        } else {
            self.tokenOutputs.append(tokenOutput)
        }
        tableView.reloadData()
    }
}

extension TokensViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        presenter?.didPushPreview(viewControllerToCommit)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: tableView.convert(location, from: view)) else {
            return nil
        }
        
        return presenter?.didPreview(tokenOutputs[indexPath.item].id)
    }
}

extension TokensViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenOutputs.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tokenOutput = tokenOutputs[indexPath.item]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenViewCell", for: indexPath) as? TokenViewCell else {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "TokenViewCell")
            cell.textLabel?.text = tokenOutput.name
            cell.detailTextLabel?.text = "\(tokenOutput.balance) \(tokenOutput.ticker)"
            return cell
        }
        
        cell.backgroundColor = UIColor.clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.themBlue
        
        cell.selectedBackgroundView = bgColorView
        cell.tokenOutput = tokenOutput
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didPushToken(tokenOutputs[indexPath.item].id)
    }
}

extension TokensViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        var data = [String: Any]()
        var tokens = [[String:String]]()
        tokenOutputs.forEach { (tokenOutput) in
            var token = [String: String]()
            token["id"] = tokenOutput.id
            token["name"] = tokenOutput.name
            token["balance"] = tokenOutput.balance
            tokens.append(token)
        }
        
        data["tokens"] = tokens
        
        do { // Try to update the WatchApp
            try session.updateApplicationContext(data)
        } catch {}
    }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
