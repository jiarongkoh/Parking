//
//  Constants.swift
//  Parking
//
//  Created by Koh Jia Rong on 15/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import Foundation

struct Constants {
    
    struct AppInfo {
        static let VersionKey = "versionKey"
        
        static let VersionValue = 1.0
    }
    
    struct Firebase {
        static let HDBCarparks = "hdbCarparks"
        static let MallCarparks = "mallCarparks"
        static let URACarparks = "uraCarparks"
    }
    
    
    struct URA {
        static let AccessKey = "063de07f-c1b7-4bd5-992f-8b5f85fac447"
        
        static let APIScheme = "https"
        static let APIHost = "www.ura.gov.sg"
        static let APIPathForGetToken = "/uraDataService/insertNewToken.action"
        static let APIPathForCarparkDetails = "/uraDataService/invokeUraDS"
    
    }
    
    struct OneMap {
        static let APIScheme = "https"
        static let APIHost = "developers.onemap.sg"
        static let APIPathForSearch = "/commonapi/search"
        static let APIPathForConversion = "/commonapi/convert/3414to4326"
        
    }
    
    struct DataGov {
        static let APIScheme = "https"
        static let APIHost = "data.gov.sg"
        static let APIPath = "/api/action/datastore_search"
        
        static let MallsCarparkRatesResourceId = "e2468b11-6cac-42e4-8891-145c4fc1cba2"
        static let HDBCarparkRatesResourceId = "139a3035-e624-4f56-b63f-89ae28d4ae4c"
    }
    
    struct UserDefaults {
        static let CarparkList = "carparkList"
        
        static let IsFirstLaunch = "isFirstLaunch"
        static let SearchRadius = "searchRadius"
        static let UserVehicleCategory = "userVehicleCategory"
        
        static let MaxCharLength = 500
    }

}
