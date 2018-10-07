//
//  CarparkTableViewCell.swift
//  Parking
//
//  Created by Koh Jia Rong on 14/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

class DetailedCarparkTableViewCell: UITableViewCell {
    
    let carparkNameTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 20)
        l.contentMode = .left
        l.sizeToFit()
        return l
    }()
    
    let detailTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textColor = .darkGray
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.sizeToFit()
        tv.contentInset.left = -4
        tv.isUserInteractionEnabled = false
        return tv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(carparkNameTitleLabel)
        addSubview(detailTextView)
        
        carparkNameTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        carparkNameTitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        carparkNameTitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        carparkNameTitleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        detailTextView.topAnchor.constraint(equalTo: carparkNameTitleLabel.bottomAnchor, constant: 0).isActive = true
        detailTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        detailTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        detailTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
