//
//  Carpark.swift
//  Parking
//
//  Created by Koh Jia Rong on 15/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import Foundation
import MapKit


class CarparkObj: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var markerColor: UIColor?
    var title: String?
    
    var carparkName: String?
    var sundayAndPublicHolRate: String?
    var saturdayRate: String?
    var weekdayRate1: String?
    var weekdayRate2: String?
    var lat: Double?
    var long: Double?
    var carparkType: String?
    
    init(carparkName: String?, sundayAndPublicHolRate: String?, saturdayRate: String?, weekdayRate1: String?, weekdayRate2: String?, lat: Double?, long: Double?, carparkType: String?) {
        self.title = carparkName
        self.carparkName = carparkName
        self.sundayAndPublicHolRate = sundayAndPublicHolRate
        self.saturdayRate = saturdayRate
        self.weekdayRate1 = weekdayRate1
        self.weekdayRate2 = weekdayRate2
        self.lat = lat
        self.long = long
        self.coordinate = CLLocationCoordinate2DMake(lat!, long!)
        self.carparkType = carparkType
    }
}
