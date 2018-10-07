//
//  CoreDataManager.swift
//  Parking
//
//  Created by Koh Jia Rong on 21/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import CoreData

class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Carpark")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print("Loading store failed: ", error)
            }
        })
        return container
    }()
    
    override init() {
        super.init()
    }
}
