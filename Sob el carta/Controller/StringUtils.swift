//
//  StringUtils.swift
//  Sob el carta
//
//  Created by MedAmine on 8/26/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import Foundation

class StringUtils {
    
    static let shared = StringUtils()
    
    func getTicketNumber(fromText: String) -> [String]{
        let text = fromText.replacingOccurrences(of: " ", with: "")
        
        var ticketNumbers: [String] = []
        
        let textsMatchesRegex = matches(for: "\\d{14,}", in: text)
//        We will check for the length of the text by the code instead of \d{14} to limit it for maximum size of 14, because it will return the number even if its more than 14
//        Example : 1234567890123456 -> For the regex \d{14} it will return 12345678901234 and thats incorrect because the detected number may be corrupted
//        Thats why we get the full number (14 and more) then check it with code thats is exactly 14
        
        for textMatchRegex in textsMatchesRegex {
            if textMatchRegex.count == 14 {
                ticketNumbers.append(textMatchRegex)
            }
        }
        
        return ticketNumbers
    }
    
    func getTicketOperatorCode(fromText: String) -> [String] {
        let text = fromText.replacingOccurrences(of: " ", with: "")
        
        var ticketOperatorsCodes: [String] = []
        
        let textsMatchesRegex = matches(for: "\\d{0,1}(100|101|123)\\d{0,1}", in: text)
        
        for textMatchRegex in textsMatchesRegex {
            if textMatchRegex.count == 3 {
                if !ticketOperatorsCodes.contains(textMatchRegex) {
                    ticketOperatorsCodes.append(textMatchRegex)
                }
            }
        }
        
        return ticketOperatorsCodes
    }
    
    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch _ {
            return []
        }
    }
    
}
