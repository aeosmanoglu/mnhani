//
//  mapViewController.swift
//  mnhani
//
//  Created by Abuzer Emre Osmanoğlu on 10.04.2018.
//  Copyright © 2018 Abuzer Emre Osmanoğlu. All rights reserved.
//

import UIKit
import Mapbox
import CoreData

class mapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    let mapView = MGLMapView()
    @IBOutlet var button: UserLocationButton!
    @IBOutlet weak var targetView: UIImageView!
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var targetLocations = CLLocation()
    var mgrs = String()
    @IBOutlet weak var distanceLabel: UILabel!
    var annotations = [MGLAnnotation]()
    var timer = Timer()
    var memorizedCount = UserDefaults.standard.integer(forKey: "Count")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        mapView.styleURL = MGLStyle.outdoorsStyleURL()
        mapView.userTrackingMode = MGLUserTrackingMode.follow
        view.addSubview(mapView)
        view.insertSubview(targetView, aboveSubview: mapView)
        view.insertSubview(distanceLabel, aboveSubview: mapView)
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        segmentControl()
        setupLocationButton()
        
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
    
    // MARK: - Map Buttons
    func segmentControl() {
        let styleToggle = UISegmentedControl(items: ["Topographic", "Satalite"])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.selectedSegmentIndex = 0
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(changeStyle(sender:)), for: .valueChanged)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[styleToggle]-40-|", options: [], metrics: nil, views: ["styleToggle" : styleToggle]))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: styleToggle, attribute: .bottom, relatedBy: .equal, toItem: mapView.logoView, attribute: .top, multiplier: 1, constant: -20)])
    }
    
    @objc func changeStyle(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.styleURL = MGLStyle.outdoorsStyleURL()
        case 1:
            mapView.styleURL = MGLStyle.satelliteStyleURL()
        default:
            mapView.styleURL = MGLStyle.outdoorsStyleURL()
        }
    }
    
    @IBAction func locationButtonTapped(sender: UserLocationButton) {
        var mode: MGLUserTrackingMode
        
        switch (mapView.userTrackingMode) {
        case .none:
            mode = .follow
            break
        case .follow:
            mode = .followWithHeading
            break
        case .followWithHeading:
            mode = .none
            break
        case .followWithCourse:
            mode = .none
            break
        }
        mapView.userTrackingMode = mode
        sender.updateArrowForTrackingMode(mode: mode)
    }
    
    func setupLocationButton() {
        button = UserLocationButton(buttonSize: 40)
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.tintColor = mapView.tintColor
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: button.frame.size.height),
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: button.frame.size.width)
        ]
        view.addConstraints(constraints)
    }
    
    // MARK: - Core Data Fetching
    @objc func updateData() {
        var pointArray = [point]()
        pointArray.removeAll()
        pointArray = CoreDataManager.fetch()
        let count = pointArray.count
        UserDefaults.standard.set(count, forKey: "Count")
        mapView.removeAnnotations(annotations)
        if count > 0 {
            for i in 0 ... (pointArray.count - 1) {
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pointArray[i].pointLatitude, longitude: pointArray[i].pointLongitude)
                annotation.title = pointArray[i].pointTitle
                annotation.subtitle = pointArray[i].pointMGRS
                annotations.append(annotation)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: - Map View
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        targetLocations = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let distance = userLocation.distance(from: targetLocations)
        distanceLabel.text = "\(Int(distance)) m"
        mgrs = convert().toMGRS(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        navigationItem.title = mgrs
    }
    
    // MARK: - Buttons
    @IBAction func addButton(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        let alertController = UIAlertController(title: "New Point", message: "Please write your point name!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = timeString
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
            let newPointName = alertController.textFields![0]
            var title = newPointName.text
            if newPointName.text == "" {
                title = timeString
            }
            CoreDataManager.store(title: title!, mgrs: self.mgrs, latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
            self.updateData()
            self.view.makeToast("Saved", position: .top)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }

    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = mgrs
        self.view.makeToast("Coordinates copied to clipboard", position: .top)
    }

}
