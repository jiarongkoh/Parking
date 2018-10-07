//
//  AboutTableViewCell.swift
//  Parking
//
//  Created by Koh Jia Rong on 22/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {

    let textView1: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.contentMode = .left
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.sizeToFit()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.contentInset.left = -2
        tv.text = "So, why build this app?"
        return tv
    }()
    
    let titleLabel2: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 30)
        l.text = "Pain Point"
        return l
    }()
    
    let textView2: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.contentMode = .left
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.sizeToFit()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.contentInset.left = -2
        tv.text = "Have you ever encountered a situation where you parked at one location while your friends parked at another, and they tell you \"oh it’s cheaper to park there\"? \n\nYes, we know. Parking is expensive, and when you hear that, that feeling s****. Whatever. \n\nWouldn’t it be great if you already know where are the cheaper alternatives around your destination?\n\nExisting parking apps would show you the fees that you are expected to pay, but they don't show you options around your destination. You wouldn’t even know there could be a cheaper option.\n\nWith Parq’d, you can."
        return tv
    }()
    
    let titleLabel3: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 30)
        l.text = "Solution"
        return l
    }()
    
    let textView3: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.contentMode = .left
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.sizeToFit()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.contentInset.left = -2
        tv.text = "Parq’d curates all carparks located in Singapore to provide motorists finger tip access to cheaper carpark alternatives around their destination. Simply select the location you are heading to, and it will show you nearby carparks around that vicinity on a map.\n\nIt also shows you the fees that each carpark charges and that allows you to decide which carpark offers a potentially cheaper rate.\n\nSo yea, cheapest parking fee always!"
        return tv
    }()
    
    let titleLabel4: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 30)
        l.text = "Acknowledgement"
        return l
    }()
    
    let textView4: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.contentMode = .left
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.sizeToFit()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.contentInset.left = -2
        tv.text = "This app is made possible with open sourced data from data.gov.sg. Give this app a go and let us know what do you think!"
        return tv
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(textView1)
        addSubview(titleLabel2)
        addSubview(textView2)
        addSubview(titleLabel3)
        addSubview(textView3)
        addSubview(titleLabel4)
        addSubview(textView4)

        textView1.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        textView1.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        textView1.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true

        titleLabel2.topAnchor.constraint(equalTo: textView1.bottomAnchor, constant: 10).isActive = true
        titleLabel2.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        titleLabel2.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        titleLabel2.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        textView2.topAnchor.constraint(equalTo: titleLabel2.bottomAnchor, constant: 0).isActive = true
        textView2.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        textView2.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        
        titleLabel3.topAnchor.constraint(equalTo: textView2.bottomAnchor, constant: 10).isActive = true
        titleLabel3.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        titleLabel3.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        titleLabel3.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        textView3.topAnchor.constraint(equalTo: titleLabel3.bottomAnchor, constant: 0).isActive = true
        textView3.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        textView3.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        
        titleLabel4.topAnchor.constraint(equalTo: textView3.bottomAnchor, constant: 10).isActive = true
        titleLabel4.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        titleLabel4.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        titleLabel4.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        textView4.topAnchor.constraint(equalTo: titleLabel4.bottomAnchor, constant: 0).isActive = true
        textView4.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        textView4.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        textView4.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
