//
//  CoreDataService.swift
//  WhereIsMyMoto
//
//  Created by 江宗翰 on 2017/12/5.
//  Copyright © 2017年 Hank.Chiang. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService{
    
    private init(){}
    
    static let coreDataService = CoreDataService()
    
    lazy var context:NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TrackYourSpending")
        
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let storeUrl = documentsDirectory.appendingPathComponent("TrackYourSpending.sqlite")
        print("1:  \(storeUrl)")
        if !FileManager.default.fileExists(atPath: (storeUrl.path)) {
            if let seededDataUrl = Bundle.main.url(forResource: "TrackYourSpending", withExtension: "sqlite") {
                
                print("2:  \(seededDataUrl)")
                try! FileManager.default.copyItem(at: seededDataUrl, to: storeUrl)
            }
        }
        
        // 各種設定
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeUrl
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("saved")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
