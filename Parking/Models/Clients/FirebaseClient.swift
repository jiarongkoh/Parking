//
//  FirebaseClient.swift
//  Parking
//
//  Created by Koh Jia Rong on 28/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseClient: NSObject {
    static let shared = FirebaseClient()
    
    var session = URLSession.shared
    
    var ref: DatabaseReference!
    
    override init() {
        super.init()
        
        ref = Database.database().reference()
    }

    func getAllCarparks(_ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        var allMallsCarparks = [CarparkObj]()
        var allHDBCarparks = [CarparkObj]()
        var allURACarparks = [CarparkObj]()
        
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        
        downloadGroup.enter()
        getMallsCarparks { (mallsCarparks, error) in
            if let error = error {
                completionHandler(nil, error)
                downloadGroup.leave()
            } else if let mallsCarparks = mallsCarparks {
                allMallsCarparks = mallsCarparks
                downloadGroup.leave()
            }
        }
        
        downloadGroup.enter()
        getHDBCarparks { (hdbCarparks, error) in
            if let error = error {
                completionHandler(nil, error)
                downloadGroup.leave()
            } else if let hdbCarparks = hdbCarparks {
                allHDBCarparks = hdbCarparks
                downloadGroup.leave()
            }
        }
        
        downloadGroup.notify(queue: .main) {
            let allCarparks = allMallsCarparks + allHDBCarparks + allURACarparks
            completionHandler(allCarparks, nil)
        }
    }
    
    
    func getMallsCarparks(_ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        var carparks = [CarparkObj]()
        
        ref.child(Constants.Firebase.MallCarparks).observeSingleEvent(of: .value) { (snapshot) in
            let snapArray = snapshot.value as! [String: AnyObject]
            
            snapArray.forEach({ (dictionary) in
                let snapValue = dictionary.value
                
                let carparkName = snapValue["carpark"] as? String
                let saturdayRate = snapValue["saturday_rate"] as? String
                let sundayAndPublicHolRate = snapValue["sunday_public_holiday_rate"] as? String
                let weekdayRate1 = snapValue["weekdays_rate1"] as? String
                let weekdayRate2 = snapValue["weekdays_rate2"] as? String
                let carparkType = "shoppingMalls"
                
                guard
                    let lat = snapValue["lat"] as? Double,
                    let long = snapValue["long"] as? Double else {
                    return
                }
                
                let carpark = CarparkObj(carparkName: carparkName, sundayAndPublicHolRate: sundayAndPublicHolRate, saturdayRate: saturdayRate, weekdayRate1: weekdayRate1, weekdayRate2: weekdayRate2, lat: lat, long: long, carparkType: carparkType)
                carparks.append(carpark)
             })
            
            completionHandler(carparks, nil)
        }
    }
    
    func getHDBCarparks(_ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        var carparks = [CarparkObj]()
        
        ref.child(Constants.Firebase.HDBCarparks).observeSingleEvent(of: .value) { (snapshot) in
            let snapArray = snapshot.value as! [String: AnyObject]
            
            snapArray.forEach({ (dictionary) in
                let snapValue = dictionary.value
                
                guard
                    let lat = snapValue["lat"] as? Double,
                    let long = snapValue["long"] as? Double else {
                        return
                }
                let carparkType = snapValue["car_park_type"] as? String
                let carparkName = snapValue["address"] as? String
                
                var sundayAndPublicHolRate: String
                let freeParking = snapValue["free_parking"] as! String
                if freeParking == "NO" {
                    sundayAndPublicHolRate = "HDB rates apply"
                } else {
                    sundayAndPublicHolRate = "Free parking " + freeParking
                }
                
                var saturdayRate: String?
                var weekdayRate1: String?
                var weekdayRate2: String?
                
                let shortTermParking = snapValue["short_term_parking"] as! String
                let nightParking = snapValue["night_parking"] as! String
                
                if shortTermParking != "NO" {
                    weekdayRate1 = "HDB rates apply \(shortTermParking)"
                    weekdayRate2 = self.textForNightParking(nightParking: nightParking)
                    saturdayRate = "HDB rates apply \(shortTermParking) " + "\n\n" + self.textForNightParking(nightParking: nightParking)
                } else {
                    weekdayRate1 = "Season parking only"
                    weekdayRate2 = "Season parking only"
                    saturdayRate = "Season parking only"
                }
                
                let carpark = CarparkObj(carparkName: carparkName, sundayAndPublicHolRate: sundayAndPublicHolRate, saturdayRate: saturdayRate, weekdayRate1: weekdayRate1, weekdayRate2: weekdayRate2, lat: lat, long: long, carparkType: carparkType)
                carparks.append(carpark)
            })
            
            completionHandler(carparks, nil)
        }
    }
    
    func textForNightParking(nightParking: String) -> String {
        if nightParking == "YES" {
            return "Night parking chargeable"
        } else {
            return "Free night parking"
        }
    }
    
}
