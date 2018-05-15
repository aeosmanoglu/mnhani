//
//  addViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 21.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import FormToolbar
import CoreLocation

class addViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var zoneTextField: UITextField!
    @IBOutlet weak var mgrsZoneTextField: UITextField!
    @IBOutlet weak var eastTextField: UITextField!
    @IBOutlet weak var northTextField: UITextField!
    var toolbar = FormToolbar()
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var latitude = Double()
    var longitude = Double()
    var mgrs = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        zoneTextField.delegate = self
        mgrsZoneTextField.delegate = self
        eastTextField.delegate = self
        northTextField.delegate = self
        
        self.toolbar = FormToolbar(inputs: [titleTextField, eastTextField, northTextField, zoneTextField, mgrsZoneTextField])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        let converter = GeoCoordinateConverter.shared()
        mgrs = (converter?.mgrs(fromLatitude: latitude, longitude: longitude))!
        let zones = mgrs.prefix(5)
        let coordinates = mgrs.suffix(11)
        zoneTextField.placeholder = String(zones.prefix(3))
        mgrsZoneTextField.placeholder = String(zones.suffix(2))
        eastTextField.placeholder = String(coordinates.prefix(5))
        northTextField.placeholder = String(coordinates.suffix(5))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        titleTextField.placeholder = timeString
    }
    
    //MARK: - Keyboard and Text Field Attributes
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toolbar.update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { Notification in
            self.keyboardWillShow(notification: Notification)
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { Notification in
            self.keyboardWillHide(notification: Notification)
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Text Fields Limitations
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        ///Limitation
        var i = 20
        
        if textField == titleTextField {
            i = 20
        }
        
        ///Jump
        let currentCharacterCount = ((textField.text?.count)! + string.count) - 1
        
        switch (textField, currentCharacterCount) {
        case (eastTextField, 5):
            northTextField.becomeFirstResponder()
        case (northTextField, 5):
            zoneTextField.becomeFirstResponder()
        case (zoneTextField, 3):
            mgrsZoneTextField.becomeFirstResponder()
        default:
            break
        }
        
        ///Bool
        let text = textField.text ?? ""
        guard let range = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: range, with: string)
        return updatedText.count <= i
    }
    
    
    // MARK: - Buttons
    @IBAction func saveButton(_ sender: Any) {
        var title = titleTextField.text
        var zone = zoneTextField.text
        var mgrsZone = mgrsZoneTextField.text
        var east = eastTextField.text
        var north = northTextField.text
        
        if title == "" {
            title = titleTextField.placeholder
        }
        if zone == "" {
            zone = zoneTextField.placeholder
        }
        if mgrsZone == "" {
            mgrsZone = mgrsZoneTextField.placeholder
        }
        if east == "" {
            east = eastTextField.placeholder
        }
        if north == "" {
            north = northTextField.placeholder
        }
        
        
        let mgrsText = "\(zone!)\(mgrsZone!) \(east!) \(north!)"
        
        let mgrsTextLatitude = UnsafeMutablePointer<Double>.allocate(capacity: 1)
        let mgrsTextLongitude = UnsafeMutablePointer<Double>.allocate(capacity: 1)
        
        
        let converter = GeoCoordinateConverter.shared()
        _ = converter?.mgrs(mgrsText, toLatitude: mgrsTextLatitude, longitude: mgrsTextLongitude)
        
        CoreDataManager.store(title: title!, mgrs: mgrsText, latitude: mgrsTextLatitude[0], longitude: mgrsTextLongitude[0])
        self.view.makeToast(NSLocalizedString("Saved", comment: ""), position: .top)
        
        mgrsTextLatitude.deallocate()
        mgrsTextLongitude.deallocate()
        
        NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
        _ = navigationController?.popViewController(animated: true)
    }

}
