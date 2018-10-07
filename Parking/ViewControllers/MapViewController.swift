//
//  MapViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 14/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    lazy var mapView: MKMapView = {
        let v = MKMapView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.showsUserLocation = true
        v.delegate = self
        v.insetsLayoutMarginsFromSafeArea = true
        return v
    }()
    
    let line: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .lineGray
        return v
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .customGroupedTableViewBackgroundColor
        tv.contentInset.top = -24
        return tv
    }()

    
    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Weekdays", "Sat", "Sun & PH"]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .customGreen
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return sc
    }()
    
    let toolBar: UIToolbar = {
        let tb = UIToolbar()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    var locationManager: CLLocationManager!
    
    var allCarparks: [Carpark]?
    var nearbyCarparks = [Carpark]()
    var searchedCarpark: Carpark!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchData()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }

    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(mapView)
        view.addSubview(line)
        view.addSubview(tableView)
        view.addSubview(toolBar)
        
        navigationItem.title = searchedCarpark.carparkName
        
        let item = UIBarButtonItem(customView: segmentedControl)
        toolBar.items = [item]
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        line.topAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        line.leftAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        tableView.topAnchor.constraint(equalTo: line.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        
        toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        toolBar.leftAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.leftAnchor).isActive = true
        toolBar.rightAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        tableView.register(DetailedCarparkTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func fetchData() {
        filterCarparksWithinRadius()
    }
    
    func filterCarparksWithinRadius() {
        
        var allAnnotations = [Carpark]()
        
        let searchRadius = UserDefaults.standard.object(forKey: Constants.UserDefaults.SearchRadius) as! Double
        let searchedCarparkLocation = CLLocation(latitude: searchedCarpark.lat, longitude: searchedCarpark.long)

        allCarparks?.forEach({ (carpark) in
            let carparkLocation = CLLocation(latitude: carpark.lat, longitude: carpark.long)
            let distance = carparkLocation.distance(from: searchedCarparkLocation)
            
            if distance <= searchRadius && distance != 0 {
                nearbyCarparks.append(carpark)
                allAnnotations.append(carpark)
            }
        })
        
        allAnnotations.append(searchedCarpark)
        mapView.addAnnotations(allAnnotations)
        
        let zoomCoordinate = CLLocationCoordinate2D(latitude: searchedCarpark.lat, longitude: searchedCarpark.long)
        zoomMap(to: zoomCoordinate)
            
    }
    
    func calculateOffsetPercentage() -> Double {
        guard let navBarHeight = navigationController?.navigationBar.frame.size.height else {return 1.0}
        let mapViewHeight = view.frame.size.height / 2
        let otherControlsHeight =  navBarHeight + UIApplication.shared.statusBarFrame.height
        let pointOffset = mapViewHeight - otherControlsHeight
        let percentage = pointOffset / mapViewHeight
        return Double(percentage)
    }
    
    func zoomMap(to coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: false)
        
        var center = coordinate
        center.latitude -= region.span.latitudeDelta / 4.0 * calculateOffsetPercentage()
        mapView.setCenter(center, animated: false)
        mapView.selectAnnotation(searchedCarpark, animated: false)
    }
    
    func centerMap(to coordinate: CLLocationCoordinate2D, animated: Bool) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        var center = coordinate
        center.latitude -= region.span.latitudeDelta / 4.0 * calculateOffsetPercentage()
        mapView.setCenter(center, animated: animated)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !annotation.isKind(of: Carpark.self) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            let marker = annotation as! Carpark
            
            if marker.carparkName == searchedCarpark.carparkName {
                annotationView?.glyphImage = UIImage(named: "ic_flag_white")
                annotationView?.markerTintColor = .darkGray
            } else {
                annotationView?.glyphImage = UIImage(named: "ic_local_parking_white")
                annotationView?.markerTintColor = .customBlue
            }
            
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = view.annotation as! Carpark
        
        navigationItem.title = selectedAnnotation.carparkName
    }
    
}

extension MapViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Heading to..."
        } else {
            return "Nearby Carparks"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let textView = UITextView()
            textView.text = "There are no carparks around the area you are heading to..."
            textView.textColor = .darkGray
            textView.backgroundColor = .clear
            textView.textAlignment = .center
            textView.isEditable = false
            textView.isSelectable = false
            textView.isScrollEnabled = false
            textView.font = UIFont.boldSystemFont(ofSize: 16)
            return textView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return nearbyCarparks.isEmpty ? 100 : 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return nearbyCarparks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailedCarparkTableViewCell

        if indexPath.section == 0 {
            cell.carparkNameTitleLabel.text = searchedCarpark.carparkName
            cell.detailTextView.text = detailsForSegmentedControlValue(searchedCarpark)

        } else {
            let carpark = nearbyCarparks[indexPath.row]
            cell.carparkNameTitleLabel.text = carpark.carparkName
            cell.detailTextView.text = detailsForSegmentedControlValue(carpark)
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellDidLongPress))
        longPress.minimumPressDuration = 1
        cell.addGestureRecognizer(longPress)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCarpark: Carpark
        
        if indexPath.section == 0 {
            selectedCarpark = searchedCarpark
        } else {
            selectedCarpark = nearbyCarparks[indexPath.row]
        }
        
        centerMap(to: selectedCarpark.coordinate, animated: true)
        mapView.selectAnnotation(selectedCarpark, animated: true)
        navigationItem.title = selectedCarpark.carparkName
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reportAction = UITableViewRowAction(style: .normal, title: "Report") { (action, indexPath) in
            var selectedCarpark: Carpark

            if indexPath.section == 0 {
                selectedCarpark = self.searchedCarpark
            } else {
                selectedCarpark = self.nearbyCarparks[indexPath.row]
            }
            
            let vc = ReportViewController()
            let navController = UINavigationController(rootViewController: vc)
            vc.carpark = selectedCarpark
            self.present(navController, animated: true, completion: nil)
        }
        
        return [reportAction]
    }
}

extension MapViewController {
    func detailsForSegmentedControlValue(_ carpark: Carpark) -> String {
        var detailInfo = ""
        
        switch segmentedControl.selectedSegmentIndex  {
        case 0:
            if let weekdayRate1 = carpark.weekdayRate1 {
                if let weekdayRate2 = carpark.weekdayRate2 {
                    detailInfo = weekdayRate1 + "\n\n" + weekdayRate2
                } else {
                    detailInfo = weekdayRate1
                }
            }
        case 1:
            if let saturdayRate = carpark.saturdayRate {
                detailInfo = saturdayRate
            }
        case 2:
            if let sundayAndPublicHolRate = carpark.sundayAndPublicHolRate {
                detailInfo = sundayAndPublicHolRate
            }
        default:
            detailInfo = ""
        }
        
        return detailInfo
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @objc func cellDidLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = longPressGestureRecognizer.location(in: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            
            var coordinate = CLLocationCoordinate2D()
            var carparkName: String
            
            if indexPath.section == 0 {
                coordinate = CLLocationCoordinate2D(latitude: searchedCarpark.lat, longitude: searchedCarpark.long)
                carparkName = searchedCarpark.carparkName!
            } else {
                let selectedCarpark = nearbyCarparks[indexPath.row]
                coordinate = CLLocationCoordinate2D(latitude: selectedCarpark.lat, longitude: selectedCarpark.long)
                carparkName = selectedCarpark.carparkName!
            }
            
            
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let openInMapsAction = UIAlertAction(title: "Open in Maps", style: .default, handler: { (action) in
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
                mapItem.name = carparkName
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            })
            
            let openInGoogleMapsAction = UIAlertAction(title: "Open in Google Maps", style: .default, handler: { (_) in
                let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving")
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)

            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertVC.addAction(openInMapsAction)
            
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                alertVC.addAction(openInGoogleMapsAction)
            }
            
            alertVC.addAction(cancelAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
}
