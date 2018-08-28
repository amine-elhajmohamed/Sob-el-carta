//
//  TicketController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/28/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit
import FirebaseMLVision

class TicketController {
    
    static let shared = TicketController()
    
    private lazy var vision = Vision.vision()
    private lazy var textRecognizer = vision.onDeviceTextRecognizer()
    
    /**
     First String parametre its the operator code
     Seconde String paramtre its the ticket number
     -> return (nil, nil) when the ticket number not found even if valid operator code exist
     */
    func analyseImage(image: UIImage, searchForOperatorCode: Bool, onComplition: @escaping ((String?, String?)->())) {
        startTextRecognizer(image: image, onComplition: { (text: String?) in
            guard let text = text else {
                onComplition(nil, nil)
                return
            }
            
            guard let ticketNumber = StringUtils.shared.getTicketNumber(fromText: text).first else {
                onComplition(nil, nil)
                return
            }
            
            var operatorCode: String? = nil
            
            if searchForOperatorCode {
                operatorCode = StringUtils.shared.getTicketOperatorCode(fromText: text).first
            }
            
            onComplition(operatorCode, ticketNumber)
        })
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
    
}
