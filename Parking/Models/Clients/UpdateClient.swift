//
//  UpdateClient.swift
//  Parking
//
//  Created by Koh Jia Rong on 28/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//


//Raw code to update firebase
import Foundation
import FirebaseDatabase

class UpdateClient: NSObject {
    static let shared = UpdateClient()
    
    var session = URLSession.shared
    
    var ref: DatabaseReference!
    
    override init() {
        super.init()
        
        ref = Database.database().reference()
    }
    
    func getMallsCarparksFromDataGov(_ locationText: String, _ completionHandler: @escaping (_ carparks: [MallsCarparkStruct]?, _ error: Error?) -> Void) {
        
        let parameters = ["resource_id": Constants.DataGov.MallsCarparkRatesResourceId,
                          "q": locationText,
                          "limit": 500
            ] as [String: AnyObject]
        let url = urlFromParameters(apiScheme: Constants.DataGov.APIScheme, apiHost: Constants.DataGov.APIHost, apiPath: Constants.DataGov.APIPath, parameters)
        
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
                        
                        carparkRecords.forEach({ (carparkDictionary) in
                            self.ref.child("mallCarparks").childByAutoId().updateChildValues(carparkDictionary)
                        })

                    }
                })
            }
        }
        
        dataTask.resume()
    }
    
    func getHDBCarparksFromDataGov(_ completionHandler: @escaping (_ carparks: [HDBCarparkStruct]?, _ error: Error?) -> Void) {
        let parameters = ["resource_id": Constants.DataGov.HDBCarparkRatesResourceId,
                          "limit": 10000
            ] as [String: AnyObject]
        let url = urlFromParameters(apiScheme: Constants.DataGov.APIScheme, apiHost: Constants.DataGov.APIHost, apiPath: Constants.DataGov.APIPath, parameters)

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
                                self.ref.child("hdbCarparks").childByAutoId().updateChildValues(carparkDictionary)
                            })
                            
                        }
                    }
                })
            }
        }
        
        dataTask.resume()
    }
    
    func updateLatLong() {
        ref.child("mallCarparks").observeSingleEvent(of: .value) { (snapshot) in
            let snapValues = snapshot.value as! [String: AnyObject]
            
            var parameters = ["returnGeom": "Y",
                              "getAddrDetails": "N"]
            let downloadGroup = DispatchGroup()
            let _ = DispatchQueue.global(qos: .userInitiated)
            
            snapValues.forEach({ (values) in
                let snapKey = values.key
                let dict = values.value as! [String: AnyObject]
                
                let carparkName = dict["carpark"] as! String
                
                parameters["searchVal"] = carparkName
                
                let url = self.urlFromParameters(apiScheme: Constants.OneMap.APIScheme, apiHost: Constants.OneMap.APIHost, apiPath: Constants.OneMap.APIPathForSearch, parameters as [String : AnyObject])
                 downloadGroup.enter()
                
                let dataTask = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let data = data {
                        self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                            if let error = error {
                                print(error.localizedDescription)
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
                                
                                let data = ["lat": lat,
                                            "long": long]
                                self.ref.child("mallCarparks").child(snapKey).updateChildValues(data)
                                
                                downloadGroup.leave()
                            }
                        })
                    }
                })
                
                dataTask.resume()
                
            })
        }
    }
    
    func updateLatLongForHDB() {
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        
        ref.child("hdbCarparks").observeSingleEvent(of: .value) { (snapshot) in
            let snapValues = snapshot.value as! [String: AnyObject]
            
            snapValues.forEach({ (dictionary) in
                let snapKey = dictionary.key
                let values = dictionary.value
                let xCoord = values["x_coord"] as! String
                let yCoord = values["y_coord"] as! String

                let parameters = ["X": xCoord,
                                  "Y": yCoord] as [String: AnyObject]
                
                let url = self.urlFromParameters(apiScheme: Constants.OneMap.APIScheme, apiHost: Constants.OneMap.APIHost, apiPath: Constants.OneMap.APIPathForConversion, parameters)
                
                downloadGroup.enter()
                
                let dataTask = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let data = data {
                        self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if let results = results {
                                let resultsDictionary = results as! [String: AnyObject]
                                let lat = resultsDictionary["latitude"] as! Double
                                let long = resultsDictionary["longitude"] as! Double
                                
                                let data = ["lat": lat,
                                            "long": long]
                                self.ref.child("hdbCarparks").child(snapKey).updateChildValues(data)
                                
                                downloadGroup.leave()
                            }
                        })
                    }
                })
                
                dataTask.resume()
                
            })
        }
    }
    
    func getURACarparks() {
        URAClient.shared.getURAToken { (token, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let token = token {
                self.getCarparksFromURA(token)
            }
        }
    }
    
    
    func getCarparksFromURA(_ token: String) {
        let parameters = ["service": "Car_Park_Details"]
        let url = urlFromParameters(apiScheme: Constants.URA.APIScheme, apiHost: Constants.URA.APIHost, apiPath: Constants.URA.APIPathForCarparkDetails, parameters as [String : AnyObject])
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(Constants.URA.AccessKey, forHTTPHeaderField: "AccessKey")
        request.addValue(token, forHTTPHeaderField: "Token")
        
        let dataTask = self.session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let results = results {
                        guard let result = results as? [String: AnyObject] else {return}
                        guard let statusCode = result["Status"] as? String else {return}
                        
                        if statusCode == "Success" {
                            guard let carparkResults = result["Result"] as? [[String: AnyObject]] else {return}
                            
                            carparkResults.forEach({ (carparkDict) in
                                self.ref.child("uraCarparks").childByAutoId().updateChildValues(carparkDict)
                            })
                        }
                    }
                })
            }
        }
    
        dataTask.resume()
    }
    
    func convertLatLong() {
        let downloadGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        
        ref.child("uraCarparks").observeSingleEvent(of: .value) { (snapshot) in
            let snapValues = snapshot.value as! [String: AnyObject]
            
            snapValues.forEach({ (dictionary) in
                let key = dictionary.key
                let values = dictionary.value as! [String: AnyObject]

                if let geometries = values["geometries"] as? [[String: AnyObject]] {
                    if geometries.count > 3 {

                    } else {
                        let geometry = geometries[0]
                        guard let svy21AsString = geometry["coordinates"] as? String else {return}
                        let northings = self.convertFromSVY21(svy21AsString).0
                        let eastings = self.convertFromSVY21(svy21AsString).1

                        let parameters = ["X": northings,
                                          "Y": eastings] as [String: AnyObject]

                        let url = self.urlFromParameters(apiScheme: Constants.OneMap.APIScheme, apiHost: Constants.OneMap.APIHost, apiPath: Constants.OneMap.APIPathForConversion, parameters)

                        downloadGroup.enter()

                        let dataTask = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if let data = data {
                                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else if let results = results {
                                        let resultsDictionary = results as! [String: AnyObject]
                                        let lat = resultsDictionary["latitude"] as! Double
                                        let long = resultsDictionary["longitude"] as! Double

                                        let data = ["coordinates": svy21AsString,
                                                    "lat": lat,
                                                    "long": long] as [String : Any]
                                        self.ref.child("uraCarparks").child(key).child("geometries").childByAutoId().updateChildValues(data)
                                        self.ref.child("uraCarparks").child(key).child("geometries").child("0").removeValue()
                                        downloadGroup.leave()
                                    }
                                })
                            }
                        })

                        dataTask.resume()
                    }
                }
            })
        }
    }
    
}
