//
//  LineDataManager.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 24.05.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

struct line {
    var lineTitle:String!
    var lineLatitude:String!
    var lineLongitude:String!
    
    init(title: String, latitude: String, longitude: String) {
        lineTitle = title
        lineLatitude = latitude
        lineLongitude = longitude
    }
}

class LineDataManager: NSObject {
    
    // Delegate
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // Store Point in Core Data
    class func store (title: String, latitude: String, longitude: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Line", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObj.setValue(title, forKey: "title")
        managedObj.setValue(latitude, forKey: "latitude")
        managedObj.setValue(longitude, forKey: "longitude")
        
        do {
            try context.save()
            print("line saved!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Fetch Points from Core Data
    class func fetch (selectedScopeIdx:Int?=nil, targetText:String?=nil) -> [line]{
        var coordinates = [line]()
        let fetchRequest:NSFetchRequest<Line> = Line.fetchRequest()
        do {
            let fetchResult = try getContext().fetch(fetchRequest)
            for item in fetchResult {
                let newLine = line(title: item.title!, latitude: item.latitude!, longitude: item.longitude!)
                coordinates.append(newLine)
            }
        }catch {
            print(error.localizedDescription)
        }
        return coordinates
    }
    
    // Clean All Core Data
    class func cleanCoreData() {
        let fetchRequest:NSFetchRequest<Line> = Line.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            print("deleting all lines")
            try getContext().execute(deleteRequest)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    // Delete Data
    class func delete (line: Line) {
        let context = getContext()
        context.delete(line)
        
        do {
            try context.save()
            print("line deleted")
        }catch {
            print(error.localizedDescription)
        }
    }
    
    class func fetchObject() -> [Line]? {
        let context = getContext()
        var line: [Line]? = nil
        do {
            line = try context.fetch(Line.fetchRequest())
            return line
        }catch {
            return line
        }
    }
}
