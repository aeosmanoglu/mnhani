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
    var jointAnnotations = [MGLAnnotation]()
    var lines = [MGLPolyline]()
    var styleToggle = UISegmentedControl()
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var addView: MDCFloatingButton!
    @IBOutlet weak var copyView: MDCFloatingButton!
    @IBOutlet weak var doneView: MDCFloatingButton!
    @IBOutlet weak var addLineView: MDCFloatingButton!
    var isAlertSheetActive = true
    var lineTitle = String()
    var jointLatitudeArray = [Double]()
    var jointLongitudeArray = [Double]()
    

    
    
    
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
        view.insertSubview(addView, aboveSubview: mapView)
        view.insertSubview(copyView, aboveSubview: mapView)
        view.insertSubview(doneView, aboveSubview: mapView)
        view.insertSubview(addLineView, aboveSubview: mapView)
        doneView.isHidden = true
        addLineView.isHidden = true
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        segmentControl()
        setupLocationButton()
        
        updateData()

        NotificationCenter.default.addObserver(self, selector: #selector(updateDataNotification(notification:)), name: NSNotification.Name(rawValue: "Update"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPointNotification(notification:)), name: NSNotification.Name(rawValue: "Center"), object: nil)
        
        
    }
    
    
    
    
    
    // MARK: - Map Buttons
    func segmentControl() {
        styleToggle = UISegmentedControl(items: [NSLocalizedString("Topographic", comment: ""), NSLocalizedString("Satellite", comment: "")])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.selectedSegmentIndex = 0
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(changeStyle(sender:)), for: .valueChanged)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[styleToggle]-40-|", options: [], metrics: nil, views: ["styleToggle" : styleToggle]))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: styleToggle, attribute: .bottom, relatedBy: .equal, toItem: mapView.logoView, attribute: .top, multiplier: 1, constant: 0)])
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
        
        ///POINT
        var pointArray = [point]()
        pointArray.removeAll()
        pointArray = CoreDataManager.fetch()
        let count = pointArray.count
        mapView.removeAnnotations(annotations)
        if count > 0 {
            for i in 0 ... (count - 1) {
                let annotation = CustomPointAnnotationView()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pointArray[i].pointLatitude, longitude: pointArray[i].pointLongitude)
                annotation.title = pointArray[i].pointTitle
                annotation.subtitle = pointArray[i].pointMGRS
                //annotation.willUseImage = false
                annotations.append(annotation)
                mapView.addAnnotation(annotation)
            }
        }
        
        ///LINE
        var linesArray = [line]()
        linesArray.removeAll()
        linesArray = lineDataManager.fetch()
        let linesCount = linesArray.count
        mapView.removeOverlays(lines)
        if linesCount > 0 {
            for i in 0 ... (linesCount - 1) {
                let latitude = convert().stringToArray(linesArray[i].lineLatitude)
                let longitude = convert().stringToArray(linesArray[i].lineLongitude)
                var coordinates = [CLLocationCoordinate2D]()
                
                if (latitude?.count)! >= 1 {
                    for j in 0 ... ((latitude?.count)! - 1) {
                        coordinates.append(CLLocationCoordinate2D(latitude: latitude![j], longitude: longitude![j]))
                    }
                }
                
                if coordinates.count >= 2 {
                    let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
                    lines.append(polyline)
                    mapView.addOverlays(lines)
                    coordinates.removeAll()
                }
            }
        }
    }
    
    
    
    
    
    // MARK: - Map View
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    /* CUSTOM CALLOUT
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        // Instantiate and return our custom callout view.
        return CustomCalloutView(representedObject: annotation)
    } */
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if UserDefaults.standard.bool(forKey: "centerSwitch") {
            mapView.setCenter(annotation.coordinate, animated: true)
        }
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
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let castAnnotation = annotation as? CustomPointAnnotationView {
            if (castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        
        
        // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
        let reuseIdentifier = "DotView"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1)
        }
        
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            //return CustomUserLocationAnnotationView()
            return nil
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        if let castAnnotation = annotation as? CustomPointAnnotationView {
            if (!castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        // For better performance, always try to reuse existing annotations.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "Plus")
        
        // If there is no reusable annotation image available, initialize a new one.
        if(annotationImage == nil) {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "Joint")!, reuseIdentifier: "Plus")
        }
        
        return annotationImage
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        showPoint()
    }
    
    func showPoint() {
        if UserDefaults.standard.bool(forKey: "ShowPoint") {
            let center = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "Latitude"), longitude: UserDefaults.standard.double(forKey: "Longitude"))
            mapView.setCenter(center, zoomLevel: mapView.zoomLevel, direction: mapView.direction, animated: true)
            UserDefaults.standard.set(false, forKey: "ShowPoint")
        }
    }
    
    
    
    
    
    // MARK: - Buttons
    ///ADD BUTTON
    @IBAction func addButton(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("NewPoint", comment: "" ), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addPoint()
        })
        let saveAction = UIAlertAction(title: NSLocalizedString("NewLine", comment: "" ), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addLine()
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "" ), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        if isAlertSheetActive {
          self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    ///ADD POINT
    func addPoint() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        let alertController = UIAlertController(title: NSLocalizedString("NewPoint", comment: "" ), message: NSLocalizedString("PleaseWriteYourPointName!", comment: ""), preferredStyle: .alert)
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
            MDCSnackbarManager.setBottomOffset(50)
            MDCSnackbarManager.show(message)
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    ///COPY BUTTON
    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = mgrs
        
        let message = MDCSnackbarMessage()
        message.text = NSLocalizedString("CoordinatesCopiedToClipboard", comment: "")
        MDCSnackbarManager.setBottomOffset(50)
        MDCSnackbarManager.show(message)
    }
    
    ///ADD LINE
    func addLine() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        let alertController = UIAlertController(title: NSLocalizedString("NewLine", comment: "" ), message: NSLocalizedString("PleaseWriteYourLineName!", comment: ""), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = timeString
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words
            textField.keyboardAppearance = .dark
        }
        
        let saveButton = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [unowned alertController] _ in
            let newPointName = alertController.textFields![0]
            self.lineTitle = newPointName.text!
            if self.lineTitle == "" {
                self.lineTitle = timeString
            }
            
            self.copyView.isHidden = true
            self.addView.isHidden = true
            self.isAlertSheetActive = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.doneView.isHidden = false
                self.addLineView.isHidden = false
            })
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    ///DONE BUTTON
    @IBAction func doneButton(_ sender: Any) {
        mapView.removeAnnotations(jointAnnotations)
        doneView.isHidden = true
        addLineView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAlertSheetActive = true
            self.copyView.isHidden = false
            self.addView.isHidden = false
        }
        lineDataManager.store(title: lineTitle, latitude: convert().arrayToString(jointLatitudeArray), longitude: convert().arrayToString(jointLongitudeArray))
        NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
        
        let message = MDCSnackbarMessage()
        message.text = NSLocalizedString("Saved", comment: "")
        MDCSnackbarManager.setBottomOffset(50)
        MDCSnackbarManager.show(message)
    }
    
    ///ADD JOINT
    @IBAction func addLineButton(_ sender: Any) {
        let joint = self.mapView.centerCoordinate
        let jointLatitude = joint.latitude
        let jointLongitude = joint.longitude
        jointLatitudeArray.append(jointLatitude)
        jointLongitudeArray.append(jointLongitude)
        
        let jointAnnotation = CustomPointAnnotationView()
        jointAnnotation.willUseImage = true
        jointAnnotation.coordinate = joint
        jointAnnotations.append(jointAnnotation)
        mapView.addAnnotation(jointAnnotation)
    }
    
    
    
    
    
    // MARK: -Notifications
    @objc func updateDataNotification (notification: NSNotification) {
        updateData()
    }
    
    @objc func showPointNotification (notification: NSNotification) {
        showPoint()
    }

}



