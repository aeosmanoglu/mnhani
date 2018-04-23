//
//  CoreDataManager.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 18.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import CoreData

struct point {
    var pointTitle:String!
    var pointMGRS:String!
    var pointLatitude:Double!
    var pointLongitude:Double!
    
    init(title: String, mgrs: String, latitude: Double, longitude: Double) {
        pointTitle = title
        pointMGRS = mgrs
        pointLatitude = latitude
        pointLongitude = longitude
    }
}

class CoreDataManager: NSObject {
    
    // Delegate
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // Store Point in Core Data
    class func store (title: String, mgrs: String, latitude: Double, longitude: Double) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Annotations", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObj.setValue(title, forKey: "title")
        managedObj.setValue(mgrs, forKey: "mgrs")
        managedObj.setValue(latitude, forKey: "latitude")
        managedObj.setValue(longitude, forKey: "longitude")
        
        do {
            try context.save()
            print("saved!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Fetch Points from Core Data
    class func fetch (selectedScopeIdx:Int?=nil, targetText:String?=nil) -> [point]{
        var array = [point]()
        let fetchRequest:NSFetchRequest<Annotations> = Annotations.fetchRequest()
        do {
            let fetchResult = try getContext().fetch(fetchRequest)
            for item in fetchResult {
                let newPoint = point(title: item.title!, mgrs: item.mgrs!, latitude: item.latitude, longitude: item.longitude)
                array.append(newPoint)
            }
        }catch {
            print(error.localizedDescription)
        }
        return array
    }
    
    // Clean All Core Data
    class func cleanCoreData() {
        let fetchRequest:NSFetchRequest<Annotations> = Annotations.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            print("deleting all contents")
            try getContext().execute(deleteRequest)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    // Delete Data
    
    class func deleteObject () {
    }
}
