//
//  editViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 28.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import FormToolbar

class editViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var zoneTextField: UITextField!
    @IBOutlet weak var mgrsZoneTextField: UITextField!
    @IBOutlet weak var eastTextField: UITextField!
    @IBOutlet weak var northTextField: UITextField!
    var toolbar = FormToolbar()
    var indexPFSR = Int()
    var pointArray = [point]()

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
        
        updateData()
        placeHolders()
        
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
        
        var i: Int
        
        switch textField {
        case titleTextField:
            i = 20
        case zoneTextField:
            i = 3
        case mgrsZoneTextField:
            i = 2
        default:
            i = 5
        }
        
        let text = textField.text ?? ""
        guard let range = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: range, with: string)
        return updatedText.count <= i
    }
    
    func placeHolders() {
        let mgrs = pointArray[indexPFSR].pointMGRS
        let zones = mgrs?.prefix(6)
        let coordinates = mgrs?.suffix(11)
        zoneTextField.placeholder = String((zones?.prefix(3))!)
        mgrsZoneTextField.placeholder = String((zones?.suffix(2))!)
        eastTextField.placeholder = String((coordinates?.prefix(5))!)
        northTextField.placeholder = String((coordinates?.suffix(5))!)
        titleTextField.placeholder = pointArray[indexPFSR].pointTitle
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
        
        
        let mgrsText = "\(zone!) \(mgrsZone!) \(east!) \(north!)"
        let zoneNumber = Double(zone!.prefix(2))
        let zoneLetter = String(zone!.suffix(1))
        
        let textedLocation = convert().toDD(zoneNumber: zoneNumber!, zoneLetter: zoneLetter, mgrsZoneLetter: mgrsZone!, mgrsE: Double(east!)!, mgrsN: Double(north!)!)
        
        CoreDataManager.store(title: title!, mgrs: mgrsText, latitude: textedLocation.coordinate.latitude, longitude: textedLocation.coordinate.longitude)
        self.view.makeToast(NSLocalizedString("Saved", comment: "Saved"), position: .top)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        deleteSelectedData()
        self.view.makeToast(NSLocalizedString("Deleted", comment: "Deleted"), position: .top)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showButton(_ sender: Any) {
    }
    

}
