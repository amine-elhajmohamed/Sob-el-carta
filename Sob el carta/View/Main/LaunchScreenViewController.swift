//
//  LaunchScreenViewController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/31/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var appIcon: UIImageView!
    
    @IBOutlet weak var lblChargili: UILabel!
    @IBOutlet weak var lblRechargeQuickly: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func animateClosingView(delay: Double, onComplition: @escaping (()->())){
//        UIView.animate(withDuration: 2, animations: {
//            self.bgImg.alpha = 0
//        }) { (b) in
////            onComplition()
//        }
        
        UIView.animate(withDuration: 1, delay: delay, options: [], animations: {
            self.bgImg.alpha = 0
            self.appIcon.alpha = 0
            self.appIcon.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height*1.5).rotated(by: -55)
            self.lblChargili.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height/2)
            self.lblRechargeQuickly.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height/2)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            onComplition()
        })
        
//        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
//            self.appIcon.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
//            self.view.layoutIfNeeded()
//        }, completion: nil)
        
    }
    
}
