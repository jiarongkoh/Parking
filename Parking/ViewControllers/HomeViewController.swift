//
//  ViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 14/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .customGroupedTableViewBackgroundColor
        tv.contentInsetAdjustmentBehavior = .always
        return tv
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Carpark> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Carpark> = Carpark.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "carparkName", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch let error {
            print(error)
        }
        
        return frc
    }()
    
    var searchController = UISearchController(searchResultsController: nil)
    var searchedText: String?
    
    var carparks = [Carpark]()
    var filteredCarparks = [Carpark]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Carparks"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Where are you heading?"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        if let _ = Auth.auth().currentUser {
            loadObjects()
        } else {
            Auth.auth().signInAnonymously { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let _ = user {
                    self.loadObjects()
                }
            }
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white
                
        view.addSubview(tableView)

        navigationController?.navigationBar.tintColor = .customGreen
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsButtonDidTap))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(deleteCarparks))
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        tableView.register(CarparkTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
    }
    
    func loadObjects() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {return}

        if fetchedObjects.isEmpty {
            print("No objects in CoreData")
            
            DispatchQueue.main.async {
                JustHUD.shared.showInView(view: self.view, withHeader: nil, andFooter: "Downloading...")
            }
            
            fetchCarparks()
        } else {
            print("There are \(fetchedObjects.count) carparks in Coredata")
            
            carparks = fetchedObjects as [Carpark]
        }
    }
    
    func fetchCarparks() {
       FirebaseClient.shared.getAllCarparks { (carparks, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let carparks = carparks {
                let sortedCarparks = carparks.sorted(by: { (carpark1, carpark2) -> Bool in
                    guard let carpark1Name = carpark1.carparkName,
                        let carpark2Name = carpark2.carparkName else {
                            return false
                    }
                    
                    return carpark1Name.compare(carpark2Name) == ComparisonResult.orderedAscending
                    
                })
                
                print("Number of carparks: ", sortedCarparks.count)
                
                let context = CoreDataManager.shared.persistentContainer.viewContext
                
                sortedCarparks.forEach({ (c) in
                    let carpark = Carpark(context: context)
                    carpark.carparkName = c.carparkName
                    carpark.saturdayRate = c.saturdayRate
                    carpark.sundayAndPublicHolRate = c.sundayAndPublicHolRate
                    carpark.weekdayRate1 = c.weekdayRate1
                    carpark.weekdayRate2 = c.weekdayRate2
                    carpark.lat = c.lat!
                    carpark.long = c.long!
                    carpark.carparkType = c.carparkType
                    
                    self.carparks.append(carpark)
                })
                
                do {
                    try context.save()

                    DispatchQueue.main.async {
                        JustHUD.shared.hide()
                    }
                    
                } catch let error {
                    print(error)
                }
            } else {
                DispatchQueue.main.async {
                    print("No carparks found")
                }
            }
        }
    }
    
//    @objc func deleteCarparks() {
//        deleteAllCarparks()
//    }
    
    func deleteAllCarparks() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Carpark.fetchRequest())
        
        do {
            try context.execute(batchDeleteRequest)
            
            var indexPathsToRemove = [IndexPath]()
            
            for (index, _) in carparks.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            carparks.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
            
        } catch let delErr {
            print("Failed to delete objects from Core Data:", delErr)
        }
    }
    
    @objc func settingsButtonDidTap() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
    }
    
  
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering() {
            return filteredCarparks.count
        }
        return carparks.count

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CarparkTableViewCell
        let carpark: Carpark
        
        if isFiltering() {
            carpark = filteredCarparks[indexPath.row]
        } else {
            carpark = carparks[indexPath.row]
        }
        
        cell.carparkNameTitleTextView.text = carpark.carparkName
        cell.carparkType = carpark.carparkType
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let carpark: Carpark
        
        if isFiltering() {
            carpark = filteredCarparks[indexPath.row]
        } else {
            carpark = carparks[indexPath.row]
        }
        
        let vc = MapViewController()
        vc.searchedCarpark = carpark
        vc.allCarparks = carparks
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCarparks = carparks.filter({( carpark: Carpark) -> Bool in
            return (carpark.carparkName?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }    

}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

