//
//  AboutViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 22/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    var sectionHeaders = ["", "Pain Point", "Solution", "Acknowledgement"]
    var content = ["So, why build this app?",
                   
                   "Have you ever encounter a situation where you parked at one location while your friends parked at another, and they tell you \"oh it’s cheaper to park there\"? \n\nYes, we know. Parking is expensive, and when you hear that, that feeling s***. Whatever. \n\n Wouldn’t it be great if you already know where are the cheaper alternatives around your destination?\n\nExisting parking apps would show you information about the fees, but doesn’t show you options around your destination. You wouldn’t even know there could be a cheaper option.\n\nWith Parq’d, you can.",
                   
                   "Parq’d curates all carparks located in Singapore to provide motorists finger tip access to the cheaper carpark alternatives to their destination. Simply select the location you are heading to, and it shows you nearby carparks around that vicinity on a map.\n\nIt also shows you the fees that each carpark charges and that allows you to decide which carpark offers a potentially cheaper rate.\n\nSo yea, cheapest parking fee always!",
                   
                   "This app is made possible with open sourced data from data.gov.sg. Give this app a go and let us know what do you think!"
                   ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        if let title = title {
            navigationItem.title = title
        }
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.register(AboutTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
    }
}

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AboutTableViewCell
        cell.selectionStyle = .none
        
        return cell
    }
}
