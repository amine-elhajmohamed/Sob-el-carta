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
    @IBOutlet weak var viewContaintOperatorsViews: UIView!
    @IBOutlet weak var bgViewForSelectedOperator: UIView!
    @IBOutlet weak var ooredooView: UIView!
    @IBOutlet weak var orangeView: UIView!
    @IBOutlet weak var tunisieTelecomView: UIView!
    
    @IBOutlet weak var lblOperatorName: UILabel!
    
    @IBOutlet var cameraViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var ooredooViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var orangeViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var tunisieTelecomViewTapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var switchDetectOperatorAutomatically: UISwitch!
    @IBOutlet weak var switchDetectDetectCardAutomatically: UISwitch!
    
    @IBOutlet weak var constarintSettingsReviewMenuBottom: NSLayoutConstraint!
    @IBOutlet weak var constarintSettingsViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constarintBgViewForSelectedOperatorCentreXOoredoo: NSLayoutConstraint!
    @IBOutlet weak var constarintBgViewForSelectedOperatorCentreXOrange: NSLayoutConstraint!
    @IBOutlet weak var constarintBgViewForSelectedOperatorCentreXTunisieTelecom: NSLayoutConstraint!
    
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
        
        bgViewForSelectedOperator.layer.cornerRadius = 15
    }
    
    private func loadSettingsData(){
        let operatorFromSettings = Operators(rawValue: Settings.shared.selectedOperator ?? "")
        selectOperator(operatorFromSettings)
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
    
    private func selectOperator(_ phoneOperator: Operators?) {
        Settings.shared.selectedOperator = phoneOperator?.rawValue
        lblOperatorName.text = phoneOperator?.rawValue ?? "Automatique"
        
        guard let phoneOperator = phoneOperator else{
            bgViewForSelectedOperator.alpha = 0
            switchDetectOperatorAutomatically.isOn = true
            constarintBgViewForSelectedOperatorCentreXOoredoo.priority = UILayoutPriority.defaultLow
            constarintBgViewForSelectedOperatorCentreXOrange.priority = UILayoutPriority.defaultHigh
            constarintBgViewForSelectedOperatorCentreXTunisieTelecom.priority = UILayoutPriority.defaultLow
            return
        }
        
        let performAnimation = { (block: @escaping (()->())) in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
                block()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        switch phoneOperator {
        case .ooredoo:
            performAnimation({
                self.constarintBgViewForSelectedOperatorCentreXOoredoo.priority = UILayoutPriority.defaultHigh
                self.constarintBgViewForSelectedOperatorCentreXOrange.priority = UILayoutPriority.defaultLow
                self.constarintBgViewForSelectedOperatorCentreXTunisieTelecom.priority = UILayoutPriority.defaultLow
            })
        case .orange:
            performAnimation({
                self.constarintBgViewForSelectedOperatorCentreXOoredoo.priority = UILayoutPriority.defaultLow
                self.constarintBgViewForSelectedOperatorCentreXOrange.priority = UILayoutPriority.defaultHigh
                self.constarintBgViewForSelectedOperatorCentreXTunisieTelecom.priority = UILayoutPriority.defaultLow
            })
        case .tunisieTelecom:
            performAnimation({
                self.constarintBgViewForSelectedOperatorCentreXOoredoo.priority = UILayoutPriority.defaultLow
                self.constarintBgViewForSelectedOperatorCentreXOrange.priority = UILayoutPriority.defaultLow
                self.constarintBgViewForSelectedOperatorCentreXTunisieTelecom.priority = UILayoutPriority.defaultHigh
            })
        }
        
        if bgViewForSelectedOperator.alpha == 0 {
            UIView.animate(withDuration: 0.1) {
                self.bgViewForSelectedOperator.alpha = 1
            }
        }
        
        switchDetectOperatorAutomatically.isOn = false
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
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case switchDetectOperatorAutomatically:
            if sender.isOn {
                selectOperator(nil)
            } else {
                loadSettingsData()
                if Settings.shared.selectedOperator == nil {
                    let alertVC = UIAlertController(title: "", message: "Vous devez choisir l'opérateur depuis le menu afin de désactiver la fonctionnalité de detection automatique", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    present(alertVC, animated: true, completion: nil)
                }
            }
        case switchDetectDetectCardAutomatically:
            break
        default:
            break
        }
    }
    
    @IBAction func tapGestureTaped(_ sender: UITapGestureRecognizer) {
        switch sender {
        case cameraViewTapGesture:
            startLokingForTicketNumberFromCamera()
        case ooredooViewTapGesture:
            selectOperator(.ooredoo)
        case orangeViewTapGesture:
            selectOperator(.orange)
        case tunisieTelecomViewTapGesture:
            selectOperator(.tunisieTelecom)
        default:
            break
        }
        
    }
}

