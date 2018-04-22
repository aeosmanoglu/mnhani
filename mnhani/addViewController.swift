//
//  addViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 21.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import FormToolbar

class addViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var zoneTextField: UITextField!
    @IBOutlet weak var mgrsZoneTextField: UITextField!
    @IBOutlet weak var eastTextField: UITextField!
    @IBOutlet weak var northTextField: UITextField!
    var toolbar = FormToolbar()
    

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

        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toolbar.update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //viewWillDisappear(animated)
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
    
    
    // MARK: - Buttons
    @IBAction func saveButton(_ sender: Any) {
        
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        
    }
    
    @IBAction func showButton(_ sender: Any) {
    }
    

}
