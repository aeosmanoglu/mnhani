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
    
    // MARK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        let altitude = userLocation.altitude
        let roundedAltitude = Int(round(altitude))
        altitudeLabel.text = "\(roundedAltitude) m"
        
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        let converter = GeoCoordinateConverter.shared()
        mgrs = (converter?.mgrs(fromLatitude: latitude, longitude: longitude))!
        locationLabel.text = String(mgrs.prefix(5))
        locationTenLabel.text = String(mgrs.suffix(11))
    }
    
    // MARK: - Buttons
    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = mgrs
        self.view.makeToast(NSLocalizedString("CoordinatesCopiedToClipboard", comment: ""), position: .top)
    }
    
    @IBAction func addButton(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        let alertController = UIAlertController(title: NSLocalizedString("NewPoint", comment: ""), message: NSLocalizedString("PleaseWriteYourPointName!", comment: ""), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = timeString
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words
            textField.keyboardAppearance = .dark
        }
        
        let saveButton = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [unowned alertController] _ in
            let newPointName = alertController.textFields![0]
            newPointName.keyboardAppearance = .dark
            var title = newPointName.text
            if title == "" {
                title = timeString
            }
            CoreDataManager.store(title: title!, mgrs: self.mgrs, latitude: self.latitude, longitude: self.longitude)
            self.view.makeToast(NSLocalizedString("Saved", comment: ""), position: .top)
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
}
