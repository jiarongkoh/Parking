//
//  DataGovClient.swift
//  Parking
//
//  Created by Koh Jia Rong on 15/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit

class DataGovClient: NSObject {
    static let shared = DataGovClient()
    
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func getCarparks(_ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        
        var allCarparks = [CarparkObj]()
        var allMallsCarparks = [CarparkObj]()
        var allHDBCarparks = [CarparkObj]()
        var allURACarparks = [CarparkObj]()
        
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        
        downloadGroup.enter()
        getMallsCarparksFromDataGov("") { (mallResults, error) in
            if let error = error {
                completionHandler(nil, error)
                downloadGroup.leave()
            } else if let mallResults = mallResults {
                self.getLocationInfoFromOneMap(mallResults, { (mallCarparks, error) in
                    if let error = error {
                        completionHandler(nil, error)
                        downloadGroup.leave()
                    } else if let mallCarparks = mallCarparks {
                        allMallsCarparks = mallCarparks
                        downloadGroup.leave()
                    }
                })
            }
        }
        
        downloadGroup.enter()
        getHDBCarparksFromDataGov({ (hdbResults, error) in
            if let error = error {
                completionHandler(nil, error)
                downloadGroup.leave()
            } else if let hdbResults = hdbResults{
                self.convertLocationFromOneMapForHDBCarparks(hdbResults, { (hdbCarparks, error) in
                    if let error = error {
                        completionHandler(nil, error)
                        downloadGroup.leave()
                    } else if let hdbCarparks = hdbCarparks {
                        allHDBCarparks = hdbCarparks
                        downloadGroup.leave()
                    }
                })
            }
        })
        
//        downloadGroup.enter()
//        URAClient.shared.getURAToken { (token, error) in
//            if let error = error {
//                completionHandler(nil, error)
//                downloadGroup.leave()
//            } else if let token = token {
//                URAClient.shared.getCarparksFromURA(token, { (uraCarparkResults, error) in
//                    if let error = error {
//                        completionHandler(nil, error)
//                        downloadGroup.leave()
//                    } else if let uraCarparkResults = uraCarparkResults {
//                        URAClient.shared.convertLocationFromOneMapForURACarparks(uraCarparkResults, { (uraCarparks, error) in
//                            if let error = error {
//                                completionHandler(nil, error)
//                                downloadGroup.leave()
//                            } else if let uraCarparks = uraCarparks {
//                                allURACarparks = uraCarparks
//                                downloadGroup.leave()
//                            }
//                        })
//                    }
//                })
//            }
//        }
        
        downloadGroup.notify(queue: .main) {
            allCarparks = allHDBCarparks + allMallsCarparks + allURACarparks
            completionHandler(allCarparks,nil)
        }
    }
    
    
    func getMallsCarparksFromDataGov(_ locationText: String, _ completionHandler: @escaping (_ carparks: [MallsCarparkStruct]?, _ error: Error?) -> Void) {
        
        let parameters = ["resource_id": Constants.DataGov.MallsCarparkRatesResourceId,
                          "q": locationText,
                          "limit": 500
                            ] as [String: AnyObject]
        let url = dataGovURLFromParameters(parameters)
        
        var carparks = [MallsCarparkStruct]()
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else if let results = results {
                        guard let array = results["result"] as? [String:AnyObject] else {return}
                        guard let carparkRecords = array["records"] as? [[String: AnyObject]] else {return}

                        if carparkRecords.isEmpty {
                            completionHandler(nil, nil)
                        } else {
                            carparkRecords.forEach({ (carparkDictionary) in
                                let carparkName = carparkDictionary["carpark"] as? String
                                let saturdayRate = carparkDictionary["saturday_rate"] as? String
                                let sundayAndPublicHolRate = carparkDictionary["sunday_public_holiday_rate"] as? String
                                let weekdayRate1 = carparkDictionary["weekdays_rate1"] as? String
                                let weekdayRate2 = carparkDictionary["weekdays_rate2"] as? String
                                let carparkType = "shoppingMalls"
                                
                                let carpark =  MallsCarparkStruct(carparkName: carparkName, sundayAndPublicHolRate: sundayAndPublicHolRate, saturdayRate: saturdayRate, weekdayRate1: weekdayRate1, weekdayRate2: weekdayRate2, lat: nil, long: nil, carparkType: carparkType)
                                carparks.append(carpark)
                            })
                            
                            completionHandler(carparks, nil)
                        }
                    }
                })
            }
        }
        
        dataTask.resume()
    }
    
    func getLocationInfoFromOneMap(_ carparks: [MallsCarparkStruct], _ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        var parameters = ["returnGeom": "Y",
                          "getAddrDetails": "N"]
        
        var carparkResults = [CarparkObj]()
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)

        if carparks.isEmpty {
            completionHandler(nil, nil)
        } else {
            carparks.forEach { (carpark) in
                parameters["searchVal"] = carpark.carparkName
                
                let url = oneMapURLFromParameters(apiPath: Constants.OneMap.APIPathForSearch, parameters as [String : AnyObject])
                downloadGroup.enter()
                let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else if let data = data {
                        self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                            if let error = error {
                                completionHandler(nil, error)
                            } else if let results = results {
                                var lat: Double?
                                var long: Double?

                                guard let dictionary = results["results"] as? [[String: AnyObject]], !dictionary.isEmpty else {
                                    downloadGroup.leave()
                                    return
                                }
      
                                let geometryResults = dictionary[0]
                                lat = Double(geometryResults["LATITUDE"] as! String)
                                long = Double(geometryResults["LONGTITUDE"] as! String)
                                
                                let updatedCarpark = CarparkObj(carparkName: carpark.carparkName, sundayAndPublicHolRate: carpark.sundayAndPublicHolRate, saturdayRate: carpark.saturdayRate, weekdayRate1: carpark.weekdayRate1, weekdayRate2: carpark.weekdayRate2, lat: lat, long: long, carparkType: carpark.carparkType)
                                carparkResults.append(updatedCarpark)
                                
                                downloadGroup.leave()
                            }
                        })
                    }
                })
                dataTask.resume()
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completionHandler(carparkResults, nil)
        }
    }
    
    func getHDBCarparksFromDataGov(_ completionHandler: @escaping (_ carparks: [HDBCarparkStruct]?, _ error: Error?) -> Void) {
        let parameters = ["resource_id": Constants.DataGov.HDBCarparkRatesResourceId,
                          "limit": 10000
                            ] as [String: AnyObject]
        let url = dataGovURLFromParameters(parameters)
        
        var hdbCarparks = [HDBCarparkStruct]()
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else if let results = results {
                        guard let array = results["result"] as? [String:AnyObject] else {return}
                        guard let carparkRecords = array["records"] as? [[String: AnyObject]] else {return}
                        
                        if carparkRecords.isEmpty {
                            completionHandler(nil, nil)
                        } else {
                            carparkRecords.forEach({ (carparkDictionary) in
                                let carparkName = carparkDictionary["address"] as? String
                                let xCoord = carparkDictionary["x_coord"] as? String
                                let yCoord = carparkDictionary["y_coord"] as? String
                                let carparkType = carparkDictionary["car_park_type"] as? String
                                
                                var sundayAndPublicHolRate: String
                                let freeParking = carparkDictionary["free_parking"] as! String
                                if freeParking == "NO" {
                                    sundayAndPublicHolRate = "HDB rates apply"
                                } else {
                                    sundayAndPublicHolRate = "Free parking " + freeParking
                                }
                                
                                var saturdayRate: String?
                                var weekdayRate1: String?
                                var weekdayRate2: String?
                                
                                let shortTermParking = carparkDictionary["short_term_parking"] as! String
                                let nightParking = carparkDictionary["night_parking"] as! String
                                
                                if shortTermParking != "NO" {
                                    weekdayRate1 = "HDB rates apply \(shortTermParking)"
                                    weekdayRate2 = self.textForNightParking(nightParking: nightParking)
                                    saturdayRate = "HDB rates apply \(shortTermParking) " + "\n\n" + self.textForNightParking(nightParking: nightParking)
                                } else {
                                    weekdayRate1 = "Season parking only"
                                    weekdayRate2 = "Season parking only"
                                    saturdayRate = "Season parking only"
                                }
                                let hdbCarpark = HDBCarparkStruct(carparkName: carparkName, carparkType: carparkType, sundayAndPublicHolRate: sundayAndPublicHolRate, saturdayRate: saturdayRate, weekdayRate1: weekdayRate1, weekdayRate2: weekdayRate2, xCoord: (xCoord! as NSString).doubleValue, yCoord: (yCoord! as NSString).doubleValue, lat: nil, long: nil)

                                hdbCarparks.append(hdbCarpark)
                            })
                            
                            completionHandler(hdbCarparks, nil)
                        }
                    }
                })
            }
        }
        
        dataTask.resume()
    }
    
    func convertLocationFromOneMapForHDBCarparks(_ hdbCarparks: [HDBCarparkStruct], _ completionHandler: @escaping (_ carparks: [CarparkObj]?, _ error: Error?) -> Void) {
        var updatedHDBCarparks = [CarparkObj]()
        
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        
        hdbCarparks.forEach { (hdbCarpark) in
            let parameters = ["X": hdbCarpark.xCoord,
                              "Y": hdbCarpark.yCoord] as [String: AnyObject]
            
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

                            let updatedHDBCarpark = CarparkObj(carparkName: hdbCarpark.carparkName, sundayAndPublicHolRate: hdbCarpark.sundayAndPublicHolRate, saturdayRate: hdbCarpark.saturdayRate, weekdayRate1: hdbCarpark.weekdayRate1, weekdayRate2: hdbCarpark.weekdayRate2, lat: lat, long: long, carparkType: hdbCarpark.carparkType)
                            updatedHDBCarparks.append(updatedHDBCarpark)

                            downloadGroup.leave()
                        }
                    })
                }
            })
            
            dataTask.resume()
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completionHandler(updatedHDBCarparks, nil)
        }
    }
    
    func oneMapURLFromParameters(apiPath: String, _ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.OneMap.APIScheme
        components.host = Constants.OneMap.APIHost
        components.path = apiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func dataGovURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.DataGov.APIScheme
        components.host = Constants.DataGov.APIHost
        components.path = Constants.DataGov.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func textForNightParking(nightParking: String) -> String {
        if nightParking == "YES" {
            return "Night parking chargeable"
        } else {
            return "Free night parking"
        }
    }
    

}

extension NSObject {
    
    func urlFromParameters(apiScheme: String, apiHost: String, apiPath: String, _ parameters: [String:AnyObject]?) -> URL {
        
        var components = URLComponents()
        components.scheme = apiScheme
        components.host = apiHost
        components.path = apiPath
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ results: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
            return
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    func convertFromSVY21(_ svy21String: String) -> (Double?, Double?) {
        let svy21AsArray = svy21String.split(separator: ",")
        guard let northings = Double(svy21AsArray[0]), let eastings = Double(svy21AsArray[1]) else {return (nil, nil)}
        return (northings, eastings)
    }
    
}





