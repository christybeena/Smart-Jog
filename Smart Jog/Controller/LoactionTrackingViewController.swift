//
//  ViewController.swift
//  Smart Jog
//
//  Created by Beena on 20/10/20.
//  Copyright © 2020 Christy_Beena. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation




class LoactionTrackingViewController: UIViewController {
    
    //MARK:-Properties
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    let JoggingHistoryVM = JoggingHistoryViewModel()

    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var isRunning:Bool = false{
        didSet{
               if isRunning{
                    startRunning()
                }else{
                    stopRunning()
                }
                
        }
    }
    var traveledDistance:Double = 0{
        didSet{
            totalDistanceLabel.text = "\(String(traveledDistance)) meters"
        }
    }
    var locationsVisited = [CLLocation]()


    var liveSpeed:String=""{
        didSet{
            liveSpeedLabel.text = "\(liveSpeed) m/s"
        }
    }
    var initialLocation : CLLocation!
    var finalDestination : CLLocation!

    
    //MARK:-Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var liveSpeedLabel: UILabel!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var avargeSpeedlabel: UILabel!
    override func viewDidLoad() {
            super.viewDidLoad()
            checkLocationServices()
        }
        
    @IBAction func runButtonTapped(_ sender: UIButton) {
        isRunning = isRunning ? false : true
    }
    
    @IBAction func historyButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showHistory", sender: self)
    }
    
    func startRunning(){
        runButton.setTitle("Stop", for: .normal)
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    func stopRunning(){
        runButton.setTitle("Start", for: .normal)
        calulateTotalDistance()
        calculateAvarageSpeed()
        createJoggedHistrory()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
   
    }
    
    
   
    
     //MARK:- TO add visited location to the array of locations
    
    func addLocationsToVisitedArray(locations:[CLLocation]){
            for location in locations {
                if !locationsVisited.contains(location) {
                    locationsVisited.append(location)
                }
        }
    }
    
    func calulateTotalDistance(){
        var totalDistance = 0.0
        if locationsVisited.count>0{
            for i in 1..<locationsVisited.count {
                let previousLocation = locationsVisited[i-1]
                let currentLocation = locationsVisited[i]
                totalDistance += currentLocation.distance(from: previousLocation)
            }
        }
        traveledDistance = totalDistance
    }
    func calculateAvarageSpeed(){
        if locationsVisited.count>0{
         
            let travelTime = initialLocation.timestamp.timeIntervalSince(finalDestination.timestamp)
            if travelTime > 0{
              let avarageSpeed = traveledDistance/travelTime
              avargeSpeedlabel.text = "\(String(avarageSpeed)) m/s"
            }
        }
        else{
             avargeSpeedlabel.text = "0.0 m/s"
        }

    }
    func createJoggedHistrory(){
        let geocoder = CLGeocoder()
        var startLocation:String!
        if let intialLocation = initialLocation{
            let intialLocationName = geocoder.reverseGeocodeLocation(intialLocation, completionHandler: {(placemarks, error) -> Void in
                print(intialLocation)
                guard error == nil else {
                    return
                }
                guard let placemarks = placemarks else{return}
                guard placemarks.count > 0 else {
                    print("Problem with the data received from geocoder")
                    return
                }
                let pm = placemarks[0] as! CLPlacemark
                startLocation = pm.locality
                let speed = self.avargeSpeedlabel.text ?? "0.0m/s"
                let date = self.initialLocation.timestamp.description
                let distance = self.totalDistanceLabel.text ?? "0 meters"
                
                let histrory = JoggingHistory(context: self.context!)
                histrory.avarageSpeed = speed
                histrory.date = date
                histrory.startPoint = startLocation
                histrory.totalDistance = distance
                
                
                let alert = UIAlertController(title: "You have travelled \(distance) in \(speed)", message: "Do you want to save this history", preferredStyle: .alert)
                    
                     let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                         self.JoggingHistoryVM.saveHistory()
                     })
                     alert.addAction(ok)
                let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                     })
                     alert.addAction(cancel)
                     DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                })
          
                
               
                
            })
        }
        
        
    
       
    }

    
    //MARK:- TO setup the location manager
        func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
    //MARK:- TO setup the view in map
        func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
          
        }
        
        
        func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                // Show alert letting the user know they have to turn this on.
            }
        }
        
        
        func checkLocationAuthorization() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                centerViewOnUserLocation()
                locationManager.startUpdatingLocation()
                break
            case .denied:
                // Show alert instructing them how to turn on permissions
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                // Show an alert letting them know what's up
                break
            case .authorizedAlways:

                break
            default:
                break
            }
        }
    }


    extension LoactionTrackingViewController: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     
            guard let location = locations.last else { return }
            if let intial = locations.first{
                self.initialLocation = intial
                
            }
            if let lastLocation = locations.last{
                self.finalDestination = lastLocation
            }
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            self.liveSpeed = location.speed.description
            liveSpeedLabel.text = "\(location.speed.description) m/s"
            if isRunning{
                addLocationsToVisitedArray(locations: locations)
            }
        }
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
    }
