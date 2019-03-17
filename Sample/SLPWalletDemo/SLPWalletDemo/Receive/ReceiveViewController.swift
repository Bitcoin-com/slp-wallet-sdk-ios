//
//  ReceiveViewController.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import UIKit
import Lottie

class ReceiveViewController: UIViewController {

    var presenter: ReceivePresenter?
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var segmentAddressType: UISegmentedControl!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bgAnimationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Receive"
        
        presenter?.viewDidLoad()
    }
    
    @IBAction func didSelectType(_ sender: Any) {
        presenter?.didSelectType(index: segmentAddressType.selectedSegmentIndex)
    }
    
    
    func onViewDidLoad(_ output: AddressOutput) {
        onSelectAddress(output.slpAddress)
    }
    
    func onSelectAddress(_ output: String) {
        QRCodeImageView.image = generateQRCode(data: output)
        addressLabel.text = output
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
    
}

extension ReceiveViewController {
    fileprivate func generateQRCode(data: String) -> UIImage? {
        let parameters: [String : Any] = [
            "inputMessage": data.data(using: .utf8)!,
            "inputCorrectionLevel": "L"
        ]
        let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters)
        
        guard let outputImage = filter?.outputImage else {
            return nil
        }
        
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    

}
