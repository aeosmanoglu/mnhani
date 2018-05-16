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
import MaterialComponents

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
    var styleToggle = UISegmentedControl()
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsUserHeadingIndicator = true
        mapView.styleURL = MGLStyle.outdoorsStyleURL
        
        
        view.addSubview(mapView)
        view.insertSubview(targetView, aboveSubview: mapView)
        view.insertSubview(distanceLabel, aboveSubview: mapView)
        view.insertSubview(zoomInButton, aboveSubview: mapView)
        view.insertSubview(zoomOutButton, aboveSubview: mapView)
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        segmentControl()
        setupLocationButton()
        
        updateData()

        NotificationCenter.default.addObserver(self, selector: #selector(updateDataNotification(notification:)), name: NSNotification.Name(rawValue: "Update"), object: nil)
        
    }
    
    
    // MARK: - Map Buttons
    func segmentControl() {
        styleToggle = UISegmentedControl(items: [NSLocalizedString("Topographic", comment: ""), NSLocalizedString("Satellite", comment: "")])
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
            mapView.styleURL = MGLStyle.outdoorsStyleURL
        case 1:
            mapView.styleURL = MGLStyle.satelliteStreetsStyleURL
        default:
            mapView.styleURL = MGLStyle.outdoorsStyleURL
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
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: button.frame.size.height),
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: button.frame.size.width)
        ]
        view.addConstraints(constraints)
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        var zoom = mapView.zoomLevel
        zoom = zoom + 1
        mapView.setZoomLevel(zoom, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        var zoom = mapView.zoomLevel
        zoom = zoom - 1
        mapView.setZoomLevel(zoom, animated: true)
    }
    
    
    // MARK: - Core Data Fetching
    @objc func updateData() {
        var pointArray = [point]()
        pointArray.removeAll()
        pointArray = CoreDataManager.fetch()
        let count = pointArray.count
        mapView.removeAnnotations(annotations)
        if count > 0 {
            for i in 0 ... (count - 1) {
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
        if UserDefaults.standard.bool(forKey: "centerSwitch") {
            mapView.setCenter(annotation.coordinate, animated: true)
        }
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        targetLocations = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let distance = userLocation.distance(from: targetLocations)
        let meter = Int(distance)
        if distance > 999 {
            distanceLabel.text = convert().toKM(meter: distance)
        } else {
            distanceLabel.text = "\(meter) m"
        }
        
        distanceLabel.isHidden = UserDefaults.standard.bool(forKey: "distanceSwitch")
        
        let converter = GeoCoordinateConverter.shared()
        mgrs = (converter?.mgrs(fromLatitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))!
        navigationItem.title = mgrs
        
        mapView.showsScale = UserDefaults.standard.bool(forKey: "scaleSwitch")
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
    }
    
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
    }
    
    
    // MARK: - Buttons
    @IBAction func addButton(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        let alertController = UIAlertController(title: NSLocalizedString("NewPoint", comment: ""), message: NSLocalizedString("PleaseWriteYourPointName!", comment: ""), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = timeString
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words
            textField.keyboardAppearance = .dark
        }
        
        let saveButton = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [unowned alertController] _ in
            let newPointName = alertController.textFields![0]
            var title = newPointName.text
            if title == "" {
                title = timeString
            }
            CoreDataManager.store(title: title!, mgrs: self.mgrs, latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
            
            let message = MDCSnackbarMessage()
            message.text = NSLocalizedString("Saved", comment: "")
            MDCSnackbarManager.show(message)
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }

    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = mgrs
        
        let message = MDCSnackbarMessage()
        message.text = NSLocalizedString("CoordinatesCopiedToClipboard", comment: "")
        MDCSnackbarManager.setBottomOffset(50)
        MDCSnackbarManager.show(message)
    }
    
    @objc func updateDataNotification (notification: NSNotification) {
        updateData()
    }

}
