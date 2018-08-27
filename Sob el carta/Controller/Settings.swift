//
//  Settings.swift
//  Sob el carta
//
//  Created by MedAmine on 8/27/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import Foundation

class Settings {
    
    static let shared = Settings()
    
    var selectedOperator: String {
        get {
            let selectedOperator = UserDefaults.standard.value(forKey: "SelectedOperator") as? String
            return selectedOperator ?? "Automatic"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "SelectedOperator")
        }
    }
    
    var detectOperatorAutomatically: Bool {
        get {
            let detectOperatorAutomatically = UserDefaults.standard.value(forKey: "DetectOperatorAutomatically") as? Bool
            return detectOperatorAutomatically ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "DetectOperatorAutomatically")
        }
    }
    
    var scanCardAutomatically: Bool {
        get {
            let detectOperatorAutomatically = UserDefaults.standard.value(forKey: "ScanCardAutomatically") as? Bool
            return detectOperatorAutomatically ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "ScanCardAutomatically")
        }
    }
    
}
