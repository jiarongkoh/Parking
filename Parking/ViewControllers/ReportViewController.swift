//
//  ReportViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 28/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Eureka

class ReportViewController: FormViewController {
    
    var carpark: Carpark!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        ref = Database.database().reference()
        
        form
            +++ Section()
            <<< PushRow<String>("issuesCategory") {
                $0.title = "Issues Category"
                $0.options = ["Incorrect location", "Incorrect fees", "Others"]
                }.onPresent { from, to in
                    to.view.layoutSubviews()
                    to.tableView?.backgroundColor = .customGroupedTableViewBackgroundColor
                    to.navigationItem.largeTitleDisplayMode = .never
                }
            
            +++ Section()

            <<< TextAreaRow("description") {
                $0.placeholder = "Description"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                }
    }
    
    func setupViews() {
        tableView.backgroundColor = .customGroupedTableViewBackgroundColor
        
        navigationController?.navigationBar.tintColor = .customGreen
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Report"
        navigationItem.largeTitleDisplayMode = .always
        
        setupLeftCloseButton(title: "Cancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitButtonDidTap))
    }
    
    @objc func submitButtonDidTap() {
        let valuesDictionary = form.values()
        
        guard
            let issuesText = valuesDictionary["description"] as? String,
            let issuesCategory = valuesDictionary["issuesCategory"] as? String else {
                
                let alertVC = UIAlertController(title: "Opps!", message: "Seems like one of the field is empty.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertVC.addAction(okAction)
                present(alertVC, animated: true, completion: nil)
                return
            }
        
        var userUID = ""
        
        if let user = Auth.auth().currentUser {
            userUID = user.uid
        }
        
        let reportInformation = ["description": issuesText,
                                 "issuesCategory": issuesCategory,
                                 "carparkName": carpark.carparkName as Any,
                                 "carparkType": carpark.carparkType as Any,
                                 "lat": carpark.coordinate.latitude,
                                 "long": carpark.coordinate.longitude,
                                 "reportedBy": userUID,
                                 "timestamp": prettyTimestamp()
                                ] as [String : Any]

        ref.child("reports").childByAutoId().updateChildValues(reportInformation) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
