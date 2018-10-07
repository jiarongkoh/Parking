//
//  URAClient.swift
//  Parking
//
//  Created by Koh Jia Rong on 18/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import Foundation
import UIKit

class URAClient: NSObject {
    
    static let shared = URAClient()
    
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func getURAToken(_ completionHandlerForGetToken: @escaping (_ results: String?, _ error: NSError?) -> Void) {
        let url = urlFromParameters(apiScheme: Constants.URA.APIScheme, apiHost: Constants.URA.APIHost, apiPath: Constants.URA.APIPathForGetToken, nil)
        let request = NSMutableURLRequest(url: url)
        request.addValue(Constants.URA.AccessKey, forHTTPHeaderField: "AccessKey")
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                completionHandlerForGetToken(nil, error as NSError)
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                    if let error = error {
                        completionHandlerForGetToken(nil, error as NSError)
                    }
                    
                    guard let result = result as? [String: AnyObject] else {return}
                    guard let statusCode = result["Status"] as? String else {return}
                    
                    if statusCode == "Success" {
                        let token = result["Result"] as! String
                        completionHandlerForGetToken(token, nil)
                    }
                })
            }
        }
        
        dataTask.resume()
    }
    
    func getCarparksFromURA(_ token: String, _ completionHandler: @escaping (_ carparks: [URACarparkStruct]?, _ error: Error?) -> Void) {
        guard let userVehCat = UserDefaults.standard.object(forKey: Constants.UserDefaults.UserVehicleCategory) as? String else {return}
        
        let parameters = ["service": "Car_Park_Details"]
        let url = urlFromParameters(apiScheme: Constants.URA.APIScheme, apiHost: Constants.URA.APIHost, apiPath: Constants.URA.APIPathForCarparkDetails, parameters as [String : AnyObject])
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(Constants.URA.AccessKey, forHTTPHeaderField: "AccessKey")
        request.addValue(token, forHTTPHeaderField: "Token")
        
        var uraCarparks = [URACarparkStruct]()
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else if let results = results {
                        guard let result = results as? [String: AnyObject] else {return}
                        guard let statusCode = result["Status"] as? String else {return}
                        
                        if statusCode == "Success" {
                            guard let carparkResults = result["Result"] as? [[String: AnyObject]] else {return}
                            
                            carparkResults.forEach({ (result) in
                                guard
                                    let ppName = result["ppName"] as? String,
                                    let vehCat = result["vehCat"] as? String
                                    else {
                                        return
                                }
                                
                                if vehCat == userVehCat {
                                    if let geometries = result["geometries"] as? [[String: AnyObject]] {
                                        if geometries.count > 1 {
                                            for geometry in geometries {
                                                guard let svy21AsString = geometry["coordinates"] as? String else {return}
                                                let northings = self.convertFromSVY21(svy21AsString).0
                                                let eastings = self.convertFromSVY21(svy21AsString).1
                                                let carpark = URACarparkStruct(carparkName: ppName, xCoord: northings, yCoord: eastings, lat: nil, long: nil)
                                                uraCarparks.append(carpark)
                                            }
                                        } else {
                                            let geometry = geometries[0]
                                            guard let svy21AsString = geometry["coordinates"] as? String else {return}
                                            let northings = self.convertFromSVY21(svy21AsString).0
                                            let eastings = self.convertFromSVY21(svy21AsString).1
                                            let carpark = URACarparkStruct(carparkName: ppName, xCoord: northings, yCoord: eastings, lat: nil, long: nil)
                                            uraCarparks.append(carpark)
                                        }
                                    }
                                }
                            })
                        }
                        
                        completionHandler(uraCarparks, nil)
                    }
                })
            }
        }
        
        dataTask.resume()
        
    }
    
    //TODO: Refactor
    func convertLocationFromOneMapForURACarparks(_ uraCarparks: [URACarparkStruct], _ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        var updatedURACarparks = [CarparkObj]()
        
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        
        uraCarparks.forEach { (uraCarpark) in
            let parameters = ["X": uraCarpark.xCoord,
                              "Y": uraCarpark.yCoord] as [String: AnyObject]
            
            let url = urlFromParameters(apiScheme: Constants.OneMap.APIScheme, apiHost: Constants.OneMap.APIHost, apiPath: Constants.OneMap.APIPathForConversion, parameters)
            
            downloadGroup.enter()
            
            let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else if let data = data {
                    self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                        if let error = error {
                            completionHandler(nil, error)
                        } else if let results = results {
                            let resultsDictionary = results as! [String: AnyObject]
                            let lat = resultsDictionary["latitude"] as! Double
                            let long = resultsDictionary["longitude"] as! Double
                            
                            let updatedURACarpark = CarparkObj(carparkName: uraCarpark.carparkName, sundayAndPublicHolRate: nil, saturdayRate: nil, weekdayRate1: nil, weekdayRate2: nil, lat: lat, long: long, carparkType: "URA Type")
                            updatedURACarparks.append(updatedURACarpark)
                            
                            downloadGroup.leave()
                        }
                    })
                }
            })
            
            dataTask.resume()
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completionHandler(updatedURACarparks, nil)
        }
    }
    
    
    
}
