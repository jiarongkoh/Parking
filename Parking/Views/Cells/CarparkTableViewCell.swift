//
//  CarparkTableViewCell.swift
//  Parking
//
//  Created by Koh Jia Rong on 21/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

class CarparkTableViewCell: UITableViewCell {
    let carparkTypeBackgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 22
        iv.layer.masksToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let carparkTypeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .white
        return iv
    }()
    
    let carparkNameTitleTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.boldSystemFont(ofSize: 18)
        tv.contentMode = .left
        tv.textContainer.maximumNumberOfLines = 2
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.sizeToFit()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        return tv
    }()

    var carparkType: String? {
        didSet {
            carparkTypeBackgroundImageView.backgroundColor = colorForCarparkType(carparkType: carparkType!)
            carparkTypeIconImageView.image = imageForCarparkType(carparkType: carparkType!)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(carparkTypeBackgroundImageView)
        addSubview(carparkTypeIconImageView)
        addSubview(carparkNameTitleTextView)
        
        carparkTypeBackgroundImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        carparkTypeBackgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        carparkTypeBackgroundImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        carparkTypeBackgroundImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        carparkTypeIconImageView.centerYAnchor.constraint(equalTo: carparkTypeBackgroundImageView.centerYAnchor).isActive = true
        carparkTypeIconImageView.centerXAnchor.constraint(equalTo: carparkTypeBackgroundImageView.centerXAnchor).isActive = true
        carparkTypeIconImageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        carparkTypeIconImageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        carparkNameTitleTextView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        carparkNameTitleTextView.leftAnchor.constraint(equalTo: carparkTypeBackgroundImageView.rightAnchor, constant: 15).isActive = true
        carparkNameTitleTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func colorForCarparkType(carparkType: String) -> UIColor {
        switch carparkType {
        case "MULTI-STOREY CAR PARK":
            return UIColor.brown
        case "SURFACE CAR PARK":
            return UIColor.orange
        case "shoppingMalls":
            return UIColor.customPurple
        default:
            return UIColor.darkGray
        }
    }
    
    func imageForCarparkType(carparkType: String) -> UIImage {
        switch carparkType {
        case "MULTI-STOREY CAR PARK":
            return (UIImage(named: "ic_multistorey_carpark")?.withRenderingMode(.alwaysTemplate))!
        case "SURFACE CAR PARK":
            return (UIImage(named: "ic_outdoor_carpark")?.withRenderingMode(.alwaysTemplate))!
        case "shoppingMalls":
            return (UIImage(named: "ic_local_mall_white")?.withRenderingMode(.alwaysTemplate))!
        default:
            return (UIImage(named: "ic_local_parking_white")?.withRenderingMode(.alwaysTemplate))!
        }
    }
    
}

