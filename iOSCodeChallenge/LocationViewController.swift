//
//  ViewController.swift
//  iOSCodeChallenge
//
//  Created by Deepthi on 11/02/21.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class LocationViewController: UIViewController,CLLocationManagerDelegate {
    var locationManager : CLLocationManager = CLLocationManager()
    let radius = 100 // Radius of geofence
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager.delegate = self
        setupGeofence()
        
        
        
        
        // Do any additional setup after loading the view.
    }

    //Setup of geofence
    func setupGeofence() {
        let geoFenceRegionCenter = CLLocationCoordinate2DMake(17.3850, 78.4867)// Hyderabad Location
        let geofenceRadiusRegion = CLCircularRegion(center: geoFenceRegionCenter, radius: CLLocationDistance(radius), identifier: "notifyMeOnExit")
        geofenceRadiusRegion.notifyOnEntry = true
        geofenceRadiusRegion.notifyOnExit = true
        locationManager.startMonitoring(for: geofenceRadiusRegion)
    }

    //Location Manager delegate for Entry
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let enterRegion:CLCircularRegion = region as? CLCircularRegion else{
            return
        }
        let latitude = "\(enterRegion.center.latitude)"
        let longitude = "\(enterRegion.center.longitude)"
        let curTime = "\(Date().timeIntervalSinceNow)"
        print("Entered into location",enterRegion.center.latitude)
        self.saveLocationDetailsInCoredata(lat: latitude, long: longitude, time: curTime, type: "Entry")
        self.showAlertOnScreen(message: "You entered into geofence", title: "Hello")
    }
    
    //Location Manager delegate for Exit
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit from location")
        guard let enterRegion:CLCircularRegion = region as? CLCircularRegion else{
            return
        }
        let latitude = "\(enterRegion.center.latitude)"
        let longitude = "\(enterRegion.center.longitude)"
        let curTime = "\(Date().timeIntervalSinceNow)"
        self.saveLocationDetailsInCoredata(lat: latitude, long: longitude, time: curTime, type: "Exit")
        self.showAlertOnScreen(message:"You exited from Geofence", title: "Bye!")
    }
    
    //Save location data into coredata
    func saveLocationDetailsInCoredata(lat:String, long:String, time:String, type:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Location", in : managedContext)
        else{
            return
        }
                let record = NSManagedObject(entity: entity, insertInto: managedContext)
                record.setValue(lat, forKey: "latitude")
                record.setValue(long, forKey: "longitude")
                record.setValue(time, forKey: "time")
                record.setValue(type, forKey: "type")
                do {
                    try managedContext.save()
                    print("Record Added!")
                } catch
                let error as NSError {
                    print("Could not save. \(error),\(error.userInfo)")
                }
    }
}

//View controller extension for alertview

extension UIViewController {
  func showAlertOnScreen(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
}
