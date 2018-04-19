//
//  currentViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 10.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import CoreLocation

class currentViewController: UIViewController, CLLocationManagerDelegate {
    
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var latitude = Double()
    var longitude = Double()
    var mgrs = String()
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTenLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        let altitude = userLocation.altitude
        let roundedAltitude = Int(round(altitude))
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        altitudeLabel.text = "\(roundedAltitude) m"
        mgrs = convert().toMGRS(latitude: latitude, longitude: longitude)
        locationLabel.text = String(mgrs.prefix(6))
        locationTenLabel.text = String(mgrs.suffix(11))
    }
 
    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = mgrs
        self.view.makeToast("Coordinates copied to clipboard", position: .top)
    }
    
    @IBAction func addButton(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        let alertController = UIAlertController(title: "New Point", message: "Please write your point name!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = timeString
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
            let newPointName = alertController.textFields![0]
            var title = newPointName.text
            if newPointName.text == "" {
                title = timeString
            }
            CoreDataManager.store(title: title!, mgrs: self.mgrs, latitude: self.latitude, longitude: self.longitude)
            self.view.makeToast("Saved", position: .top)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
}
