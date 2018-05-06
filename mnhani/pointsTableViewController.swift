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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationWithSearchBar()
        updateData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataNotification(notification:)), name: NSNotification.Name(rawValue: "Update"), object: nil)
    }
    
    
    // MARK: - Navigation and Search Bar
    func navigationWithSearchBar() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem
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
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            pointArray.remove(at: indexPath.row)
            var point: [Point]? = nil
            point = CoreDataManager.fetchObject()
            CoreDataManager.delete (point: point![indexPath.row])
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
        } else {
            performSegue(withIdentifier: "EditSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let edit = segue.destination as! editViewController
            edit.indexPFSR = (tableView.indexPathForSelectedRow?.row)!
        }
    }
    
    // MARK: - Buttons
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "AddSegue", sender: self)
    }
    
    @objc func updateDataNotification (notification: NSNotification) {
        updateData()
    }

}
