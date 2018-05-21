//
//  settingsViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 30.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import MaterialComponents

class settingsViewController: UIViewController {
    
    @IBOutlet weak var centerS: UISwitch!
    @IBOutlet weak var distanceS: UISwitch!
    @IBOutlet weak var scaleS: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        centerS.isOn = UserDefaults.standard.bool(forKey: "centerSwitch")
        distanceS.isOn = UserDefaults.standard.bool(forKey: "distanceSwitch")
        scaleS.isOn = UserDefaults.standard.bool(forKey: "scaleSwitch")
    }


    

    // MARK: - Data

    @IBAction func deleteAllButton(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("YouRAbout2DeleteAllSavedPoints!", comment: ""), preferredStyle: .alert)
        
        let deleteButton = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (action: UIAlertAction) in
            CoreDataManager.cleanCoreData()
            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
            
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
    
    // MARK: - Map
    @IBAction func centerSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "centerSwitch")
    }
    @IBAction func distanceSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "distanceSwitch")
    }
    @IBAction func scaleSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "scaleSwitch")
    }
}
