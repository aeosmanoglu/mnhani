//
//  pointsTableViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 18.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit

class pointsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var pointArray = [point]()
    var filteredArray = [point]()
    let searchController = UISearchController(searchResultsController: nil)
    var timer = Timer()
    var memorizedCount = UserDefaults.standard.integer(forKey: "Count")
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        navigationWithSearchBar()
        updateData()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTime), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func runTime() {
        let array = CoreDataManager.fetch()
        let count = array.count
        if memorizedCount != count {
            updateData()
        }
    }
    
    // MARK: - Navigation and Search Bar
    func navigationWithSearchBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredArray = pointArray.filter({( point : point) -> Bool in
            return point.pointTitle.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - Core Data Fetching
    @objc func updateData() {
        pointArray.removeAll()
        pointArray = CoreDataManager.fetch()
        UserDefaults.standard.set(pointArray.count, forKey: "Count")
        tableView.reloadData()
    }
    
    // MARK: - Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredArray.count
        }
        return pointArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")
        let cellRow : point
        if isFiltering() {
            cellRow = filteredArray[indexPath.row]
        } else {
            cellRow = pointArray[indexPath.row]
        }
        cell?.textLabel?.text = cellRow.pointTitle
        cell?.detailTextLabel?.text = cellRow.pointMGRS
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isFiltering() {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        timer.invalidate()
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTime), userInfo: nil, repeats: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            pointArray.remove(at: indexPath.row)
            var point: [Point]? = nil
            point = CoreDataManager.fetchObject()
            CoreDataManager.delete (point: point![indexPath.row])
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Buttons
    @IBAction func deleteAllButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "You are about to delete all saved points!", preferredStyle: .alert)
        
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction) in
            CoreDataManager.cleanCoreData()
            self.updateData()
            self.view.makeToast("Deleted", position: .bottom)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
}
