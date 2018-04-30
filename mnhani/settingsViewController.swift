//
//  settingsViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 30.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    @IBAction func deleteAllButton(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: NSLocalizedString("YouRAbout2DeleteAllSavedPoints!", comment: "You are about to delete all saved points!"), preferredStyle: .alert)
        
        let deleteButton = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive) { (action: UIAlertAction) in
            CoreDataManager.cleanCoreData()
            self.view.makeToast(NSLocalizedString("Deleted", comment: "Deleted"), position: .center)
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: nil)
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
}
