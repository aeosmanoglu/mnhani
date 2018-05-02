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
}
