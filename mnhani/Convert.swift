//
//  Convert.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 13.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import Foundation

class convert {
    
    func toMGRS (latitude: Double, longitude: Double) -> String {
        
        var UTMzone = Double()
        var UTMzoneAlpha = String()
        
        // First Two numbers
        if longitude > 0 {
            UTMzone = floor((180 + longitude) / 6) + 1
        } else {
            UTMzone = floor((180 + longitude) / 6) + 31
        }
        
        // First Letter
        switch latitude {
        case -90 ... -85:
            UTMzoneAlpha = "A"
        case -84 ... -73:
            UTMzoneAlpha = "C"
        case -72 ... -65:
            UTMzoneAlpha = "D"
        case -64 ... -57:
            UTMzoneAlpha = "E"
        case -56 ... -49:
            UTMzoneAlpha = "F"
        case -48 ... -41:
            UTMzoneAlpha = "G"
        case -40 ... -33:
            UTMzoneAlpha = "H"
        case -32 ... -25:
            UTMzoneAlpha = "J"
        case -24 ... -17:
            UTMzoneAlpha = "K"
        case -16 ... -9:
            UTMzoneAlpha = "L"
        case -8 ... -1:
            UTMzoneAlpha = "M"
        case 0 ... 7:
            UTMzoneAlpha = "N"
        case 8 ... 15:
            UTMzoneAlpha = "P"
        case 16 ... 23:
            UTMzoneAlpha = "Q"
        case 24 ... 31:
            UTMzoneAlpha = "R"
        case 32 ... 39:
            UTMzoneAlpha = "S"
        case 40 ... 47:
            UTMzoneAlpha = "T"
        case 48 ... 55:
            UTMzoneAlpha = "U"
        case 56 ... 63:
            UTMzoneAlpha = "V"
        case 64 ... 71:
            UTMzoneAlpha = "W"
        case 72 ... 84:
            UTMzoneAlpha = "X"
        default:
            UTMzoneAlpha = "Z"
        }
        
        let UtmZoneCm = 6 * UTMzone - 183
        let latRad = latitude * .pi / 180
        let scaleFactor = 0.9996
        let eqRadius = 6378137.0
        let poRadius = 6356752.3142
        let eccentricity = sqrt(1 - pow(poRadius / eqRadius, 2))
        let e2 = eccentricity * eccentricity / (1 - eccentricity * eccentricity)
        let n = (eqRadius - poRadius) / (eqRadius + poRadius)
        let e100 = ["", "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let n100 = ["V", "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V"]
        
        // Meridional Arcs
        let arcA = eqRadius * (1 - n + (5 * n * n / 4) * (1 - n) + (81 * pow(n, 4) / 4) * (1 - n))
        let arcB = (3 * eqRadius * n / 2) * (1 - n - (7 * n * n / 8) * (1 - n) + 55 * pow(n, 4) / 64)
        let arcC = (15 * eqRadius * n * n / 16) * (1 - n + (3 * n * n / 4) * (1 - n))
        let arcD = (35 * eqRadius * pow(n, 3) / 48) * (1 - n + 11 * n * n / 16)
        let arcE = (315 * eqRadius * pow(n, 4) / 51) * (1 - n)
        let arcS = arcA * latRad - arcB * sin(2 * latRad) + arcC * sin(4 * latRad) - arcD * sin(6 * latRad) + arcE * sin(8 * latRad)
        let rCurv2 = eqRadius / pow(1 - pow(eccentricity * sin(latRad), 2), 0.5)
        let sin1 = .pi / (180.00 * 3600.00)
        
        // k1...k5
        let k1 = arcS * scaleFactor
        let k2 = rCurv2 * sin(latRad) * cos(latRad) * pow(sin1, 2) * scaleFactor * 100000000 / 2
        let k3 = ((pow(sin1, 4) * rCurv2 * sin(latRad) * pow(cos(latRad), 3)) / 24) * (5 - pow(tan(latRad), 2) + 9 * e2 * pow(cos(latRad), 2) + 4 * pow(e2, 2) * pow(cos(latRad), 4)) * scaleFactor * 10000000000000000
        let k4 = rCurv2 * cos(latRad) * sin1 * scaleFactor * 10000
        let k5 = pow((sin1 * cos(latRad)), 3) * (rCurv2 / 6) * (1 - pow(tan(latRad), 2) + e2 * pow(cos(latRad), 2)) * scaleFactor * 1000000000000
        
        // Deltas
        let deltaLong = longitude - UtmZoneCm
        let deltaLongSec = deltaLong * 3600 / 10000
        
        let northB = k1 + k2 * deltaLongSec * deltaLongSec + k3 * pow(deltaLongSec, 3)
        
        // UTMnorth
        var UTMnorth = Double()
        if latitude > 0 {
            UTMnorth = northB
        } else {
            UTMnorth = 10000000 + northB
        }
        
        // UTMEast
        let UTMeast = 500000 + (k4 * deltaLongSec + k5 * pow(deltaLongSec, 3))
        
        // Finding Twin Letters
        let longLtr = 8 * (UTMzone - 1).truncatingRemainder(dividingBy: 3) + 1
        let latLtr = 1 + 5 * (UTMzone - 1).truncatingRemainder(dividingBy: 2)
        
        var digLat = (longLtr + floor(UTMeast / 100000) - 1)
        var digLong = (latLtr + floor(northB / 100000)).truncatingRemainder(dividingBy: 20)
        
        // MGRS North & East
        let mgrsNorth = String(Int(floor(UTMnorth)))
        let mgrsEast = String(Int(floor(UTMeast)))
        
        //RETURN
        
        if digLat  >= 0 && digLat <= 24 {
        } else {
            digLat = 0
        }
        
        if digLong  >= 0 && digLong <= 20 {
        } else {
            digLong = 0
        }
        
        return "\(Int(UTMzone))" + "\(UTMzoneAlpha)" + " \(e100[Int(digLat)])" + "\(n100[Int(digLong)])"  + " \(String(mgrsEast.suffix(5)))" + " \(String(mgrsNorth.suffix(5)))"
    }
    
    func toKM (meter: Double) -> String {
        var decimeter = meter / 10
        decimeter = round(decimeter)
        let kilometer = decimeter / 100
        
        return String(kilometer) + " km"
    }
}
