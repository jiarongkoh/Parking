//
//  LocationSearchTableViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 14/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var getLocationDelegate: GetLocationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = matchingItems[indexPath.row].placemark
        getLocationDelegate.getPlacemark(item)

    }
    
}

extension LocationSearchTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    
}
