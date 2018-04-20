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
        let cell = UITableViewCell()
        let cellRow : point
        if isFiltering() {
            cellRow = filteredArray[indexPath.row]
        } else {
            cellRow = pointArray[indexPath.row]
        }
        cell.textLabel?.text = cellRow.pointTitle
        return cell
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
