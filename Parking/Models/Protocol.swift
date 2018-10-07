//
//  Protocol.swift
//  Parking
//
//  Created by Koh Jia Rong on 14/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import Foundation
import MapKit

protocol GetLocationDelegate {
    func getPlacemark(_ placemark: MKPlacemark)
}

protocol SearchedLocationDelegate {
    func fillTextView(with placemark: MKPlacemark)
}
