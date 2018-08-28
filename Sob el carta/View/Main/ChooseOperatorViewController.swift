//
//  ChooseOperatorViewController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/28/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit

class ChooseOperatorViewController: UIViewController {

    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var viewContaintOperatorsViews: UIView!
    @IBOutlet weak var bgViewForSelectedOperator: UIView!
    @IBOutlet weak var ooredooView: UIView!
    @IBOutlet weak var orangeView: UIView!
    @IBOutlet weak var tunisieTelecomView: UIView!
    
    @IBOutlet var ooredooViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var orangeViewTapGesture: UITapGestureRecognizer!
    @IBOutlet var tunisieTelecomViewTapGesture: UITapGestureRecognizer!
    
    var onOperatorSelection: ((Operators?)->()) = {_ in }
    
    private var isFirstTimeAnimating = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeAnimating {
            showView()
            isFirstTimeAnimating = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    private func configureView() {
        bgView.layer.cornerRadius = 15
        btnCancel.layer.cornerRadius = 5
        bgViewForSelectedOperator.layer.cornerRadius = 15
        
        bgViewForSelectedOperator.isHidden = true
        
        bgView.alpha = 0
        bgView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }
    
    private func showView(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
            self.bgView.alpha = 1
            self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hideView(onComplition: @escaping (()->())){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
            self.bgView.alpha = 0
            self.bgView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.view.layoutIfNeeded()
        }, completion: { b in
            onComplition()
        })
    }
    
    func close(onComplition: @escaping (()->())){
        hideView {
            self.dismiss(animated: false, completion: {
                onComplition()
            })
        }
    }
    
    private func selectOperator(_ phoneOperator: Operators) {
        switch phoneOperator {
        case .ooredoo:
            bgViewForSelectedOperator.center = ooredooView.center
        case .orange:
            bgViewForSelectedOperator.center = orangeView.center
        case .tunisieTelecom:
            bgViewForSelectedOperator.center = tunisieTelecomView.center
        }
        
        bgViewForSelectedOperator.isHidden = false
        
        onOperatorSelection(phoneOperator)
    }
    
    //MARK: - Actions
    
    @IBAction func tapGestureTaped(_ sender: UITapGestureRecognizer) {
        switch sender {
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
    
    @IBAction func btnClicked(_ sender: UIButton) {
        onOperatorSelection(nil)
    }
}
