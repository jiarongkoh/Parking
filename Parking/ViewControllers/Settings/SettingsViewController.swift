//
//  SettingsViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 15/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import Eureka

class SettingsViewController: FormViewController {
    
    var searchRadius: Float!
    var userVehCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchRadius = UserDefaults.standard.object(forKey: Constants.UserDefaults.SearchRadius) as! Float
        userVehCategory = UserDefaults.standard.object(forKey: Constants.UserDefaults.UserVehicleCategory) as! String
        
        setupViews()
        
        form
            +++ Section("Search Preference")
            <<< SliderRow() {
                $0.title = "Radius (m)"
                $0.minimumValue = 100
                $0.maximumValue = 500
                $0.steps = 100
                $0.value = searchRadius
                }.cellUpdate({ (cell, row) in
                    let radius = row.value
                    UserDefaults.standard.set(radius, forKey: Constants.UserDefaults.SearchRadius)
                    UserDefaults.standard.synchronize
                }).cellSetup({ (cell, row) in
                    cell.tintColor = .customGreen
                })

            <<< PushRow<String>() {
                $0.title = "Vehicle Category"
                $0.options = ["Car", "Motorcycle", "Heavy Vehicle"]
                $0.value = userVehCategory
                $0.selectorTitle = "Your Vehicle Category"
                }.onPresent { from, to in
                    to.view.layoutSubviews()
                    to.tableView?.backgroundColor = .customGroupedTableViewBackgroundColor
                    to.navigationItem.largeTitleDisplayMode = .never
                }.cellUpdate({ (cell, row) in
                    let vehCat = row.value
                    UserDefaults.standard.set(vehCat, forKey: Constants.UserDefaults.UserVehicleCategory)
                    UserDefaults.standard.synchronize
                })
            
            +++ Section("Useful Information")
            <<< ButtonRow("About Parq'd") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: { () -> UIViewController in
                    let vc = AboutViewController()
                    vc.title = "About Parq'd"
                    return vc
                }), onDismiss: nil)
            }
            
            
            <<< ButtonRow("More on Short Term Parking") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: { () -> UIViewController in
                    let vc = HDBWebViewController()
                    vc.title = "More on Short Term Parking"
                        return vc
                    }), onDismiss: nil)
            }
            
        
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Submit feedback"
                }
                .cellSetup({ (cell, row) in
                    cell.tintColor = .customGreen
                })
                .onCellSelection { (cell, row) in
                    self.submitFeedbackButtonDidTap()
        }
        
            +++ Section() { section in
                var footer = HeaderFooterView<SettingsFooterView>(.class)
                footer.height = {100}
                section.footer = footer
        }
        
    }
    
    func setupViews() {
        tableView.backgroundColor = .customGroupedTableViewBackgroundColor

        navigationController?.navigationBar.tintColor = .customGreen
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .always
        
        setupLeftCloseButton(title: "Close")
        
    }

    
    @objc func submitFeedbackButtonDidTap() {
        let vc = FeedbackViewController()
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
}
