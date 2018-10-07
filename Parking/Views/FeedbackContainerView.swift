//
//  FeedbackContainerView.swift
//  Parking
//
//  Created by Koh Jia Rong on 28/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

class FeedbackContainerView: UIView {
    let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 17)
        return tv
    }()
    
    let charactersLeftLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        l.text = "\(Constants.UserDefaults.MaxCharLength) characters left"
        l.textColor = .lightGray
        l.font = UIFont.systemFont(ofSize: 14)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(charactersLeftLabel)
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        textView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        textView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.75).isActive = true
        
        charactersLeftLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        charactersLeftLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        charactersLeftLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4).isActive = true
        charactersLeftLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
