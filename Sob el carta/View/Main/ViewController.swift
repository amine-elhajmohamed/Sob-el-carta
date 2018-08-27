//
//  ViewController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/26/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit
import FirebaseMLVision
import CameraBackground
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var btnSettings: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var viewHandleCameraViewTap: UIView!
    @IBOutlet weak var viewAboveSettingsView: UIView!
    @IBOutlet weak var settingsReviewView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var constarintSettingsReviewMenuBottom: NSLayoutConstraint!
    @IBOutlet weak var constarintSettingsViewBottom: NSLayoutConstraint!
    
    
    private lazy var vision = Vision.vision()
    private lazy var textRecognizer = vision.onDeviceTextRecognizer()
    
    private var isShowingSettingsView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        hideSettings(animated: false)
        loadSettingsData()
        
    }
    
    //MARK: - View configuration
    
    private func configureView(){
        cameraView.addCameraBackground(.back, showButtons: false)
    }
    
    private func loadSettingsData(){
        
    }
    
    private func showSettings(animated: Bool){
        isShowingSettingsView = true
        
        let todo = {
            self.constarintSettingsReviewMenuBottom.priority = UILayoutPriority(250)
            self.constarintSettingsViewBottom.priority = UILayoutPriority(999)
            self.viewAboveSettingsView.alpha = 1
            self.btnSettings.setImage(UIImage(named: "IconDown"), for: .normal)
        }
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
                todo()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }else{
            todo()
        }
        
    }
    
    private func hideSettings(animated: Bool){
        isShowingSettingsView = false
        
        let todo = {
            self.constarintSettingsViewBottom.priority = UILayoutPriority(250)
            self.constarintSettingsReviewMenuBottom.priority = UILayoutPriority(999)
            self.viewAboveSettingsView.alpha = 0
            self.btnSettings.setImage(UIImage(named: "IconSettings"), for: .normal)
        }
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
                todo()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }else{
            todo()
        }
        
    }
    
    
    private func startLokingForTicketNumberFromCamera(){
        viewHandleCameraViewTap.isUserInteractionEnabled = false
        
        let onComplitionDo = {
            self.cameraView.freeCameraSnapshot()
            self.viewHandleCameraViewTap.isUserInteractionEnabled = true
        }
        
        cameraView.takeCameraSnapshot(nil) { (image: UIImage?, error: NSError?) in
            
            guard error == nil, let image = image else {
                onComplitionDo()
                let errorOcured = 1
                return
            }
        
            self.startTextRecognizer(image: image, onComplition: { (text: String?) in
                
                guard let text = text else {
                    onComplitionDo()
                    let errorOcured = 1
                    return
                }
                
                
                
//                print(text)
                let operatorCode = StringUtils.shared.getTicketOperatorCode(fromText: text)
                let ticketNumber = StringUtils.shared.getTicketNumber(fromText: text)
                
                let alertVC = UIAlertController(title: nil, message: "*\(operatorCode.first ?? "XX")*\(ticketNumber.first ?? "XXXXXXXXXXXXXXXXXXX")#", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
                
                onComplitionDo()
            })
            
        }
    }
    
    private func startTextRecognizer(image: UIImage, onComplition: @escaping ((String?)->())){
        
        let metadata = VisionImageMetadata()
        metadata.orientation = .rightTop
        
        let image = VisionImage(image: image)
        image.metadata = metadata
        
        textRecognizer.process(image) { (visionText: VisionText?, error: Error?) in
            
            guard error == nil, let visionText = visionText else {
                onComplition(nil)
                return
            }
            
            onComplition(visionText.text)
            
        }

    }
    
    //MARK: Actions
    
    @IBAction func btnClicked(_ sender: UIButton) {
        switch sender {
        case btnSettings:
            if isShowingSettingsView {
                hideSettings(animated: true)
            }else{
                showSettings(animated: true)
            }
            
        default:
            break
        }
    }
    
    @IBAction func cameraViewTaped(_ sender: UITapGestureRecognizer) {
        startLokingForTicketNumberFromCamera()
    }
}

