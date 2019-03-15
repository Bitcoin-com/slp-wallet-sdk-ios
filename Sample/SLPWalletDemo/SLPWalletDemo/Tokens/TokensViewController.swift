//
//  TokensViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

class TokensViewController: UITableViewController {

    var tokenOutputs: [TokenOutput] = []
    var presenter: TokensPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Demo SLP SDK"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Receive", style: .plain, target: self, action: #selector(didPushReceive))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Mnemonic", style: .plain, target: self, action: #selector(didPushMnemonic))
        
        tableView.refreshControl = UIRefreshControl()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TokenViewCell", bundle: nil), forCellReuseIdentifier: "TokenViewCell")
        
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(didRefreshTokens), for: .valueChanged)
        
        // Notify our presenter that we loaded the view
        presenter?.viewDidLoad()
    }
    
    @objc func didRefreshTokens() {
        presenter?.didRefreshTokens()
    }
    
    @objc func didPushReceive() {
        presenter?.didPushReceive()
    }
    
    @objc func didPushMnemonic() {
        presenter?.didPushMnemonic()
    }
    
    func onFetchTokens(tokenOutputs: [TokenOutput]) {
        // Reload the table on fetched tokens
        self.tokenOutputs = tokenOutputs
        tableView.reloadData()
        refreshControl?.endRefreshing()
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
        presenter?.didPushToken(tokenOutputs[indexPath.item].id)
    }
}
