//
//  SettingsViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import Lottie

class SettingsViewController: UITableViewController {
    
    var presenter: SettingsPresenter?
    var settingOutputs = [SettingsEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(didPushClose))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingViewCell")
        
        // 3D touch enable if available
        if(traitCollection.forceTouchCapability == .available){
            self.registerForPreviewing(with: self, sourceView: self.view)
        }
        
        presenter?.viewDidLoad()
    }
    
    @objc func didPushClose() {
        presenter?.didPushClose()
    }
    
    func onPresenterDidLoad(_ settings: [SettingsEntity]) {
        self.settingOutputs = settings
        
        tableView.reloadData()
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingOutputs.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingOutput = settingOutputs[indexPath.item]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SettingViewCell")
        cell.textLabel?.text = settingOutput.title
        cell.textLabel?.textColor = .white
        
        cell.detailTextLabel?.text = settingOutput.description
        cell.detailTextLabel?.textColor = .white
        
        cell.backgroundColor = UIColor.clear
        
        cell.imageView?.image = UIImage(named: settingOutput.iconName)?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = .white
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.themBlue
        
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didPushSetting(indexPath.item)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -130 {
            presenter?.didPushClose()
        }
    }
}

extension SettingsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        presenter?.didPushPreview(viewControllerToCommit)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: tableView.convert(location, from: view)) else {
            return nil
        }
        
        return presenter?.didPreview(indexPath.item)
    }
}
