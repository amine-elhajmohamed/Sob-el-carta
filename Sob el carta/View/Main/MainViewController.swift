//
//  MainViewController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/26/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit
import CameraBackground
import FLAnimatedImage

class MainViewController: UIViewController {
    
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
    @IBOutlet weak var lblAlertScanCardAutomaticallyNotAvailable: UILabel!
    
    @IBOutlet var cameraViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var ooredooViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var orangeViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var tunisieTelecomViewTapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var animatedImageForAutoScan: FLAnimatedImageView!
    
    @IBOutlet weak var switchDetectOperatorAutomatically: UISwitch!
    @IBOutlet weak var switchDetectDetectCardAutomatically: UISwitch!
    
    @IBOutlet weak var constarintSettingsReviewMenuBottom: NSLayoutConstraint!
    @IBOutlet weak var constarintSettingsViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constarintBgViewForSelectedOperatorCentreXOoredoo: NSLayoutConstraint!
    @IBOutlet weak var constarintBgViewForSelectedOperatorCentreXOrange: NSLayoutConstraint!
    @IBOutlet weak var constarintBgViewForSelectedOperatorCentreXTunisieTelecom: NSLayoutConstraint!
    
    @available(iOS 11.0, *)
    private lazy var visionTextDetectionController: VisionTextDetectionController? = nil
    
    private var analysingCardInBackgroundDispatchWorkItem: DispatchWorkItem?
    
    private var isShowingSettingsView = true
    private var startVisionTextDetectionControllerWhenAppBecomeActive = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *), Settings.shared.scanCardAutomatically {
            visionTextDetectionController?.start()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        hideSettings(animated: false)
        loadSettingsData()
    }
    
    //MARK: - View configuration
    
    private func configureView(){
        cameraView.addCameraBackground(.back, showButtons: false)
        
        animatedImageForAutoScan.alpha = 0
        bgViewForSelectedOperator.layer.cornerRadius = 15
        
        if let path = Bundle.main.path(forResource: "AnimatRocket", ofType: "gif") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                animatedImageForAutoScan.animatedImage = FLAnimatedImage(animatedGIFData: data)
            }catch{}
        }
        
        if #available(iOS 11.0, *) {
            lblAlertScanCardAutomaticallyNotAvailable.text = ""
            
            if let session = cameraView.cameraLayer?.session {
                visionTextDetectionController = VisionTextDetectionController(session: session)
                visionTextDetectionController?.delegate = self
            }
        } else {
            switchDetectDetectCardAutomatically.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    private func loadSettingsData(){
        let operatorFromSettings = Operators(rawValue: Settings.shared.selectedOperator ?? "")
        selectOperator(operatorFromSettings)
        
        switchDetectDetectCardAutomatically.isOn = Settings.shared.scanCardAutomatically
    }
    
    @objc private func applicationDidBecomeActive(){
        guard startVisionTextDetectionControllerWhenAppBecomeActive else {
            return
        }
        startVisionTextDetectionControllerWhenAppBecomeActive = false
        if #available(iOS 11.0, *) {
            visionTextDetectionController?.start()
        }
    }
    
    //MARK:- Card analyse operations
    
    private func dialTicketNumber(operatorCode: String?, ticketNumber: String, onComplition: @escaping (()->())){
        let selectedOperator = Settings.shared.selectedOperator
        
        guard (selectedOperator != nil) || (operatorCode != nil) else {
            let chooseOperatorVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOperatorVC") as! ChooseOperatorViewController
            
            chooseOperatorVC.onOperatorSelection = { (selectedOperatorFromView: Operators?) in
                guard let selectedOperatorFromView = selectedOperatorFromView else {
                    chooseOperatorVC.close {
                        onComplition()
                    }
                    return
                }
                
                chooseOperatorVC.close {
                    onComplition()
                    self.dialTicketNumber(phoneOperator: selectedOperatorFromView, ticketNumber: ticketNumber)
                }
            }
            
            self.hideSettings(animated: true)
            self.present(chooseOperatorVC, animated: false, completion: nil)
            return
        }
        
        onComplition()
        
        if let phoneOperator = Operators(rawValue: selectedOperator ?? ""){
            self.dialTicketNumber(phoneOperator: phoneOperator, ticketNumber: ticketNumber)
        }else if let operatorCode = operatorCode {
            self.dialTicketNumber(operatorCode: operatorCode, ticketNumber: ticketNumber)
        }
    }
    
    private func dialTicketNumber(phoneOperator: Operators, ticketNumber: String){
        var operatorCode = ""
        
        switch phoneOperator {
        case .ooredoo:
            operatorCode = OperatorsCodes.ooredoo.rawValue
        case .orange:
            operatorCode = OperatorsCodes.orange.rawValue
        case .tunisieTelecom:
            operatorCode = OperatorsCodes.tunisieTelecom.rawValue
        }
        
        dialTicketNumber(operatorCode: operatorCode, ticketNumber: ticketNumber)
    }
    
    private func dialTicketNumber(operatorCode: String, ticketNumber: String){
        if let phoneUrl = URL(string: "tel://*\(operatorCode)*\(ticketNumber)#") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(phoneUrl)
            }
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
    
    private func startLookingForTicketNumberFromCamera(){
        viewHandleCameraViewTap.isUserInteractionEnabled = false
        stopAnalysingCardInBackground()
        if #available(iOS 11.0, *) {
            visionTextDetectionController?.stop()
        }
        
        let onComplitionDo = {
            self.cameraView.freeCameraSnapshot()
            self.viewHandleCameraViewTap.isUserInteractionEnabled = true
        }
        
        cameraView.takeCameraSnapshot(nil) { (image: UIImage?, error: NSError?) in
            
            guard error == nil, let image = image else {
                onComplitionDo()
                let alertVC = UIAlertController(title: "Erreur", message: "Échec dans le caméra, peut pas prendre le photo", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (ac) in
                    if #available(iOS 11.0, *) {
                        self.visionTextDetectionController?.start()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
                return
            }
            
            TicketController.shared.analyseImage(image: image, searchForOperatorCode: Settings.shared.selectedOperator == nil, onComplition: { (operatorCode: String?, ticketNumber: String?) in
                
                guard let ticketNumber = ticketNumber else {
                    let alertVC = UIAlertController(title: "Échec", message: "Peut pas trouver le numéro de la carte, essayez à nouveau de scanner la carte", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (ac) in
                        onComplitionDo()
                        if #available(iOS 11.0, *) {
                            self.visionTextDetectionController?.start()
                        }
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                    return
                }
                
                self.dialTicketNumber(operatorCode: operatorCode, ticketNumber: ticketNumber, onComplition: {
                    onComplitionDo()
                    self.startVisionTextDetectionControllerWhenAppBecomeActive = true
                })
            })
        }
    }
    
    @available(iOS 11.0, *)
    private func startAnalysingCardInBackground(image: UIImage){
        visionTextDetectionController?.stop()
        showIsAnalysingCardInBackground()
        
        analysingCardInBackgroundDispatchWorkItem = DispatchWorkItem {
            TicketController.shared.analyseImage(image: image, searchForOperatorCode: Settings.shared.selectedOperator == nil, onComplition: { (operatorCode: String?, ticketNumber: String?) in
                guard let analysingCardInBackgroundIsCanceled = self.analysingCardInBackgroundDispatchWorkItem?.isCancelled, !analysingCardInBackgroundIsCanceled else {
                    self.stopAnalysingCardInBackground()
                    return
                }
                
                guard let ticketNumber = ticketNumber else {
                    self.stopAnalysingCardInBackground()
                    self.visionTextDetectionController?.start()
                    return
                }
                
                self.hideIsAnalysingCardInBackground()
                
                self.dialTicketNumber(operatorCode: operatorCode, ticketNumber: ticketNumber, onComplition: {
                    self.stopAnalysingCardInBackground()
                    self.startVisionTextDetectionControllerWhenAppBecomeActive = true
                })
            })
        }
        
        DispatchQueue.global(qos: .userInteractive).async(execute: analysingCardInBackgroundDispatchWorkItem!)
    }
    
    func stopAnalysingCardInBackground(){
        analysingCardInBackgroundDispatchWorkItem?.cancel()
        analysingCardInBackgroundDispatchWorkItem = nil
        hideIsAnalysingCardInBackground()
    }
    
    //MARK:- Animations
    
    private func showSettings(animated: Bool){
        guard !isShowingSettingsView else {
            return
        }
        
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
        guard isShowingSettingsView else {
            return
        }
        
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
    
    private func showIsAnalysingCardInBackground(){
        animatedImageForAutoScan.startAnimating()
        
        UIView.animate(withDuration: 0.5) {
            self.animatedImageForAutoScan.alpha = 1
        }
    }
    
    private func hideIsAnalysingCardInBackground(){
        UIView.animate(withDuration: 0.5, animations: {
            self.animatedImageForAutoScan.alpha = 0
        }) { (b) in
            self.animatedImageForAutoScan.stopAnimating()
        }
    }
    
    //MARK:- Actions
    
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
            if #available(iOS 11.0, *) {
                Settings.shared.scanCardAutomatically = sender.isOn
                
                if sender.isOn {
                    visionTextDetectionController?.start()
                } else {
                    visionTextDetectionController?.stop()
                }
            } else {
                sender.isOn = false
            }
        default:
            break
        }
    }
    
    @IBAction func tapGestureTaped(_ sender: UITapGestureRecognizer) {
        switch sender {
        case cameraViewTapGesture:
            startLookingForTicketNumberFromCamera()
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

//MARK:- Extension : VisionTextDetectionControllerDelegate
extension MainViewController: VisionTextDetectionControllerDelegate {
    func imageContainTextDetected(image: UIImage) {
        if #available(iOS 11.0, *) {
            startAnalysingCardInBackground(image: image)
        }
    }
}
