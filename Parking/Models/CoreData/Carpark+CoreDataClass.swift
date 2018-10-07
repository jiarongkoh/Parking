//
//  Carpark+CoreDataClass.swift
//  Parking
//
//  Created by Koh Jia Rong on 22/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Carpark)
public class Carpark: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
    }
    
    public var title: String? {
        return self.carparkName
    }
}
