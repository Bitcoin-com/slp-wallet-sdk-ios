//
//  SettingsBuilder.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/26.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit

struct SettingsEntity {
    var title: String
    var description: String
    var iconName: String
    var builder: BaseBuilder
}

class SettingsBuilder {
    
    func provide() -> SettingsViewController {
        let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        
        let backupSetting = SettingsEntity(title: "Backup", description: "Mnemonic is used to backup and restore your wallet", iconName: "backup_icon", builder: BackupBuilder())
        let restoreSetting = SettingsEntity(title: "Restore", description: "Restoring a wallet will overwrite the current wallet", iconName: "restore_icon", builder: RestoreBuilder())
        
        let settings = [backupSetting, restoreSetting]
        
        let router = SettingsRouter(viewController: viewController)
        
        let presenter = SettingsPresenter(settings)
        presenter.viewDelegate = viewController
        presenter.router = router
        
        viewController.presenter = presenter
        
        return viewController
    }
}
