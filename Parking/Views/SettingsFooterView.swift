//
//  SettingsFooterView.swift
//  Parking
//
//  Created by Koh Jia Rong on 16/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import Foundation
import UIKit

class SettingsFooterView: UIView {
    
    let versionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Version " + String(Constants.AppInfo.VersionValue)
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.textAlignment = .center
        tv.textColor = .darkGray
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(versionTextView)
        
        versionTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        versionTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        versionTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        versionTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
