//
//  ViewController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/26/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit
import FirebaseMLVision

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        
        let image = VisionImage(image: UIImage(named: "CarteTest")!)
        
        
        textRecognizer.process(image) { (visionText: VisionText?, error: Error?) in
            
            guard error == nil, let visionText = visionText else {
                return
            }
            
            print(visionText.text)
            print()
            
        }
    }

}

