//
//  BackupViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import Lottie

class BackupViewController: UIViewController {
    
    var presenter: BackupPresenter?

    @IBOutlet weak var mnemonicLabel: UILabel!
    @IBOutlet weak var bgAnimationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Backup"
        
        presenter?.viewDidLoad()
    }
    
    
    @IBAction func didPushCopy(_ sender: Any) {
        presenter?.didPushCopy()
        
        let animationView = LOTAnimationView(name: "success_animation")
        animationView.frame = bgAnimationView.bounds
        bgAnimationView.addSubview(animationView)
        
        animationView.play(completion: { _ in
            animationView.removeFromSuperview()
        })
    }
    
    func onGetMnemonic(_ output: String) {
        mnemonicLabel.text = output
    }
}
