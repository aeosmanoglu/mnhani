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
import MaterialComponents

class addViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: MDCTextField!
    @IBOutlet weak var zoneTextField: UITextField!
    @IBOutlet weak var mgrsZoneTextField: UITextField!
    @IBOutlet weak var eastTextField: UITextField!
    @IBOutlet weak var northTextField: UITextField!
    var allTextFieldControllers = [MDCTextInputControllerFloatingPlaceholder]()
    var toolbar = FormToolbar()
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var latitude = Double()
    var longitude = Double()
    var mgrs = String()
    
    
    @IBOutlet weak var doneButton: MDCFloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        
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
        zoneTextField.placeholder = String(zones.prefix(2))
        mgrsZoneTextField.placeholder = String(zones.suffix(3))
        eastTextField.placeholder = String(coordinates.prefix(5))
        northTextField.placeholder = String(coordinates.suffix(5))
        
    }
    
    //MARK: - Keyboard and Text Field Attributes
    func setupTextFields() {
        titleTextField.delegate = self
        zoneTextField.delegate = self
        mgrsZoneTextField.delegate = self
        eastTextField.delegate = self
        northTextField.delegate = self
        
        let titleController = MDCTextInputControllerOutlined(textInput: titleTextField)
        titleController.placeholderText = NSLocalizedString("PointName", comment: "")
        allTextFieldControllers.append(titleController)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        titleTextField.text = timeString
    }
    
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
        case (zoneTextField, 2):
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
        let title = titleTextField.text
        var zone = zoneTextField.text
        var mgrsZone = mgrsZoneTextField.text
        var east = eastTextField.text
        var north = northTextField.text
        let message = MDCSnackbarMessage()
        MDCSnackbarManager.setBottomOffset(50)
        
        if title?.count == 0 {
            message.text = NSLocalizedString("TitleError", comment: "")
            MDCSnackbarManager.show(message)
            titleTextField.shake()
        } else if zone?.count == 1 {
            message.text = NSLocalizedString("ZoneError", comment: "")
            MDCSnackbarManager.show(message)
            zoneTextField.shake()
        } else if mgrsZone?.count == 1 || mgrsZone?.count == 2 {
            message.text = NSLocalizedString("MgrsZoneError", comment: "")
            MDCSnackbarManager.show(message)
            mgrsZoneTextField.shake()
        } else if (east?.count)! > 0 && (east?.count)! < 5 {
            message.text = NSLocalizedString("CoordinateError", comment: "")
            MDCSnackbarManager.show(message)
            eastTextField.shake()
        } else if (north?.count)! > 0 && (north?.count)! < 5 {
            message.text = NSLocalizedString("CoordinateError", comment: "")
            MDCSnackbarManager.show(message)
            northTextField.shake()
        } else {
            if zone?.count == 0 {
                zone = zoneTextField.placeholder
            }
            if mgrsZone?.count == 0 {
                mgrsZone = mgrsZoneTextField.placeholder
            }
            if east?.count == 0 {
                east = eastTextField.placeholder
            }
            if north?.count == 0 {
                north = northTextField.placeholder
            }
            
            let mgrsText = "\(zone!)\(mgrsZone!) \(east!) \(north!)"
            
            let mgrsTextLatitude = UnsafeMutablePointer<Double>.allocate(capacity: 1)
            let mgrsTextLongitude = UnsafeMutablePointer<Double>.allocate(capacity: 1)
            
            
            let converter = GeoCoordinateConverter.shared()
            _ = converter?.mgrs(mgrsText, toLatitude: mgrsTextLatitude, longitude: mgrsTextLongitude)
            
            CoreDataManager.store(title: title!, mgrs: mgrsText, latitude: mgrsTextLatitude[0], longitude: mgrsTextLongitude[0])
            
            message.text = NSLocalizedString("Saved", comment: "")
            MDCSnackbarManager.show(message)
            
            mgrsTextLatitude.deallocate()
            mgrsTextLongitude.deallocate()
            
            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
            _ = navigationController?.popViewController(animated: true)
        }
    }
}

public extension UIView {
    
    func shake(count : Float = 5, for duration : TimeInterval = 0.3, withTranslation translation : Float = 5) {
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: CGFloat(-translation), y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: CGFloat(translation), y: self.center.y))
        layer.add(animation, forKey: "shake")
    }
}
