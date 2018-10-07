//
//  SearchViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 14/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {
    
    var resultSearchController: UISearchController!
    var searchedLocationDelegate: SearchedLocationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let locationSearchTableViewController = LocationSearchTableViewController()
        resultSearchController = UISearchController(searchResultsController: locationSearchTableViewController)
        resultSearchController.searchResultsUpdater = locationSearchTableViewController as UISearchResultsUpdating
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.delegate = self
        definesPresentationContext = true
        
        locationSearchTableViewController.getLocationDelegate = self
        
        let searchBar = resultSearchController.searchBar
        searchBar.placeholder = "Search Locations"
        searchBar.sizeToFit()
        navigationItem.titleView = resultSearchController.searchBar
        setupLeftCloseButton(title: "Cancel")
    }
    
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}

extension SearchViewController: GetLocationDelegate {
    func getPlacemark(_ placemark: MKPlacemark) {
        searchedLocationDelegate.fillTextView(with: placemark)
        resultSearchController.dismiss(animated: true) {
            self.dismissVC()
        }
    }
}
