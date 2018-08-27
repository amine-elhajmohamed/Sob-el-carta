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

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var viewHandleCameraViewTap: UIView!
    @IBOutlet weak var viewAboveSettingsView: UIView!
    
    private lazy var vision = Vision.vision()
    private lazy var textRecognizer = vision.onDeviceTextRecognizer()
    
    private var isShowingSettingsView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        hideSettings()
        loadSettingsData()
        
    }
    
    //MARK: - View configuration
    
    private func configureView(){
        cameraView.addCameraBackground(.back, showButtons: false)
    }
    
    private func loadSettingsData(){
        
    }
    
    private func showSettings(){
        isShowingSettingsView = true
    }
    
    private func hideSettings(){
        isShowingSettingsView = false
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
    
    @IBAction func cameraViewTaped(_ sender: UITapGestureRecognizer) {
        startLokingForTicketNumberFromCamera()
    }
}

