//
//  Carpark+CoreDataProperties.swift
//  Parking
//
//  Created by Koh Jia Rong on 22/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//
//

import Foundation
import CoreData


extension Carpark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Carpark> {
        return NSFetchRequest<Carpark>(entityName: "Carpark")
    }

    @NSManaged public var carparkName: String?
    @NSManaged public var carparkType: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var saturdayRate: String?
    @NSManaged public var sundayAndPublicHolRate: String?
    @NSManaged public var weekdayRate1: String?
    @NSManaged public var weekdayRate2: String?

}
