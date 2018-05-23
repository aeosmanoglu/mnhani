//
//  editViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 28.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import FormToolbar
import MaterialComponents

class editViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: MDCTextField!
    @IBOutlet weak var zoneTextField: UITextField!
    @IBOutlet weak var mgrsZoneTextField: UITextField!
    @IBOutlet weak var eastTextField: UITextField!
    @IBOutlet weak var northTextField: UITextField!
    var allTextFieldControllers = [MDCTextInputControllerFloatingPlaceholder]()
    var toolbar = FormToolbar()
    var indexPFSR = Int()
    var pointArray = [point]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        
        self.toolbar = FormToolbar(inputs: [titleTextField, eastTextField, northTextField, zoneTextField, mgrsZoneTextField])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        updateData()
        placeHolders()
        
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
    
    func placeHolders() {
        let mgrs = pointArray[indexPFSR].pointMGRS
        let zones = mgrs?.prefix(5)
        let coordinates = mgrs?.suffix(11)
        zoneTextField.placeholder = String((zones?.prefix(2))!)
        mgrsZoneTextField.placeholder = String((zones?.suffix(3))!)
        eastTextField.placeholder = String((coordinates?.prefix(5))!)
        northTextField.placeholder = String((coordinates?.suffix(5))!)
        titleTextField.text = pointArray[indexPFSR].pointTitle
    }
    
    
    // MARK: - Core Data Fetching
    func updateData() {
        pointArray.removeAll()
        pointArray = CoreDataManager.fetch()
    }
    
    func deleteSelectedData() {
        pointArray.remove(at: indexPFSR)
        var point: [Point]? = nil
        point = CoreDataManager.fetchObject()
        CoreDataManager.delete (point: point![indexPFSR])
    }
    

    
    // MARK: - Navigation

    @IBAction func saveButton(_ sender: Any) {
        deleteSelectedData()
        
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
    
    @IBAction func deleteButton(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("YouRAbout2DeleteSavedPoints!", comment: ""), preferredStyle: .alert)
        
        let deleteButton = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (action: UIAlertAction) in
            self.deleteSelectedData()
            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
            _ = self.navigationController?.popViewController(animated: true)
            
            let message = MDCSnackbarMessage()
            message.text = NSLocalizedString("Deleted", comment: "")
            MDCSnackbarManager.setBottomOffset(50)
            MDCSnackbarManager.show(message)
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    @IBAction func showButton(_ sender: Any) {
        let latitude = pointArray[indexPFSR].pointLatitude
        let longitude = pointArray[indexPFSR].pointLongitude
        UserDefaults.standard.set(latitude, forKey: "Latitude")
        UserDefaults.standard.set(longitude, forKey: "Longitude")
        UserDefaults.standard.set(true, forKey: "ShowPoint")
        NotificationCenter.default.post(name: NSNotification.Name("Center"), object: nil)
        _ = self.tabBarController?.selectedIndex = 1
        
    }
    
    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = pointArray[indexPFSR].pointMGRS
        
        let message = MDCSnackbarMessage()
        message.text = NSLocalizedString("CoordinatesCopiedToClipboard", comment: "")
        MDCSnackbarManager.setBottomOffset(50)
        MDCSnackbarManager.show(message)
    }
    
}
