//
//  linesViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 1.06.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import CoreLocation

class linesViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var lineArray = [line]()
    var filteredArray = [line]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
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
        filteredArray = lineArray.filter({( line : line) -> Bool in
            return line.lineTitle.lowercased().contains(searchText.lowercased())
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
        lineArray.removeAll()
        lineArray = LineDataManager.fetch()
        tableView.reloadData()
    }
    
    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredArray.count
        }
        return lineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")
        let cellRow : line
        if isFiltering() {
            cellRow = filteredArray[indexPath.row]
        } else {
            cellRow = lineArray[indexPath.row]
        }
        cell?.textLabel?.text = cellRow.lineTitle
        cell?.detailTextLabel?.text = "\(convert().stringToArray(cellRow.lineLatitude).count)" + " " + NSLocalizedString("Joint", comment: "") + ", \(lengthOfLine(i: indexPath.row))"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isFiltering() {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            lineArray.remove(at: indexPath.row)
            var line: [Line]? = nil
            line = LineDataManager.fetchObject()
            LineDataManager.delete (line: line![indexPath.row])
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
            tableView.endUpdates()
        } else if editingStyle == .insert {
        }
    }
    
    func lengthOfLine(i: Int) -> String {
        let latitude: Array<Double>
        let longitude: Array<Double>
        if isFiltering() {
            latitude = convert().stringToArray(filteredArray[i].lineLatitude)
            longitude = convert().stringToArray(filteredArray[i].lineLongitude)
        } else {
            latitude = convert().stringToArray(lineArray[i].lineLatitude)
            longitude = convert().stringToArray(lineArray[i].lineLongitude)
        }
        var distance = 0.0
        for i in 0 ... latitude.count - 2 {
            distance = distance + CLLocation(latitude: latitude[i], longitude: longitude[i]).distance(from: CLLocation(latitude: latitude[i + 1], longitude: longitude[i + 1]))
        }
        let meter = Int(distance)
        if distance > 999 {
            return convert().toKM(meter: distance)
        } else {
            return "\(meter) m"
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
