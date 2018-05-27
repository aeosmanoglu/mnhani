//
//  Convert.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 13.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import Foundation


class convert {
    
    func toKM (meter: Double) -> String {
        var decimeter = meter / 10
        decimeter = round(decimeter)
        let kilometer = decimeter / 100
        
        return String(kilometer) + " km"
    }
    
    func arrayToString(_ DicToJSONString : [Double])-> String!{
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: DicToJSONString,
            options: []) {
            let strDicToJson:String = String(data: theJSONData,
                                             encoding: .ascii)!
            print("JSON string = \(strDicToJson)")
            return strDicToJson
        }
        return ""
    }
    
    func stringToArray(_ strToJSON : String)-> [Double]!{
        print("JsonString:\(strToJSON)");
        
        let data = strToJSON.data(using: String.Encoding.utf8)
        var array : [Double]!;
        do {
            array = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Double];
            return array;
        }
        catch let error as NSError {
            print("Error is:\(error)");
        }
        
        return array;
    }
}
