//
//  Extensions.swift
//  Parking
//
//  Created by Koh Jia Rong on 28/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

extension UIViewController {
    func toggleButtonStates(for textView: UITextView) -> Bool {
        if let text = textView.text {
            if text.count == 1 {
                let index = text.index(text.startIndex, offsetBy: 1)
                let substring = text[..<index]
                
                if substring == " " {
                    textView.text = ""
                }
            }
        }
        
        guard
            let text = textView.text, !text.isEmpty
            else {
                return false
        }
        
        return true
    }
    
    func setupLeftCloseButton(title: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(dismissVC))
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func prettyTimestamp() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyy HH:mm"
        
        return formatter.string(from: date)
    }
    
}


