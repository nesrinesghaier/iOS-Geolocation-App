//
//  MAP1ViewController.swift
//  CircularTransition
//
//  Created by SavoirPro on 17/07/2017.
//  Copyright © 2017 Training. All rights reserved.
//
import UIKit
import MapKit
import UserNotifications
import CoreLocation
import Firebase


class MAP1ViewController: UIViewController,CLLocationManagerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var textField: [UITextField]!
    
    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(MAP1ViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        /*  location manager */
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        /* USER'S LOCATION ANNOTATION */
        mapView.setUserTrackingMode(.followWithHeading , animated: false)
        mapView.delegate = self
        let droneLocation:CLLocationCoordinate2D = getJsondata()
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let Region = MKCoordinateRegionMake(droneLocation,span)
        mapView.setRegion(Region, animated: true)
        mapView.addAnnotation(Annotation(title: "Drone location", coordinate: droneLocation))
        RealtimeChanges()
    
    }
    var radius :Double = 200.0
    var oldRadius :Double = 0.0
    
    func getVal () -> Double{
        let text: String = textField[0].text!
        textField[0].text = ""
        if(Double(text) == nil){
            return 0.0
        }
        return Double(text)!
    }
    /**********************************************************************************************/
    
    func inRegion(coordinateUser:CLLocationCoordinate2D,coordinateDrone:CLLocationCoordinate2D) -> Void {
        let coordUser = CLLocation(latitude: coordinateUser.latitude, longitude: coordinateUser.longitude)
        let coordDrone = CLLocation(latitude: coordinateDrone.latitude, longitude: coordinateDrone.longitude)
        let distance = coordUser.distance(from: coordDrone)
        if (distance > radius){
            showAlert(title: "Alert", message: "Your Drone exited your region")
        }
        else {
            let title = "Your drone came back to the local region "
            let message = "Don't let it run from you !"
            showAlert(title: title, message: message)
        }
        
    }
    
    var firstTime = false
    func RealtimeChanges(){
        let  firebase = Database.database().reference().child("gpsDATA").child("867273020335464").child("currentInformation")
        firebase.observe(.value, with: {(snapshot) in
            self.mapView.removeAnnotations(self.mapView.annotations)
            let dataString = snapshot.value as! String
            CoordinateString.chainedata = dataString
            self.mapView.addAnnotation(Annotation(title: "Drone location", coordinate: self.getJsondata()))
            if(self.firstTime){
                let droneLocation:CLLocationCoordinate2D = self.getJsondata()
                let userLocation = self.mapView.userLocation.coordinate
                self.inRegion(coordinateUser: userLocation, coordinateDrone: droneLocation)
            }
        self.firstTime = true
        })
        
    }
    /**********************************************************************************************/

    func didTapView(){
        self.view.endEditing(true)
    }
    /**********************************************************************************************/
    
    func getJsondata() -> CLLocationCoordinate2D {
        let endpoint = NSURL(string: "https://gpsmakerlab.firebaseio.com/gpsDATA/867273020335464/.json"  )
        let data = NSData(contentsOf: endpoint as! URL)
        print(data as! Data)
        do {
            if let json = try JSONSerialization.jsonObject(with: data as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                
                if let dataString = json["currentInformation"] as? String {
                    OldCoord.chainedata=dataString
                    return extractCoordString(chaine: dataString)
                }
            }
        }
            //["gpsDATA"]["867273020335464"]
        catch let error as NSError{
            print("\(error)")
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    
    /**********************************************************************************************/
    
    func extractCoordString(chaine :String) -> CLLocationCoordinate2D{
        let myNSString = chaine as NSString
        let latitudeString = myNSString.substring(with: NSRange(location: 4, length: 9)) as NSString
        let longitudeString = myNSString.substring(with: NSRange(location: 17, length: 9)) as NSString
        // let speedString  = myNSString.substring(with: NSRange(location: 28, length: 4)) as NSString
        let longitude = longitudeString.doubleValue
        let latitude = latitudeString.doubleValue
        //   let speed = speedString.doubleValue
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        return coordinate
    }
    /**********************************************************************************************/
    @IBAction func track(_ sender: UIButton) {
        let userLocation = mapView.userLocation.coordinate
        let droneLocation:CLLocationCoordinate2D = getJsondata()
        if (textField[0].text != ""){
            radius = getVal()
            if(radius != oldRadius){
                mapView.removeOverlays(mapView.overlays)
                addRadiusCircle(location: mapView.userLocation.coordinate)
                oldRadius = radius
                inRegion(coordinateUser: userLocation, coordinateDrone: droneLocation)
            }
        }
    }
    /**********************************************************************************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**********************************************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = true
    }
/**********************************************************************************************/
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // showNotification(title: title, message: message)
    }
/**********************************************************************************************/
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("Get  out of there ")
        
    }
    
/*********************************************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Get  out of there ")
        
        let title = "Your Drone left the local region"
        let message = "You should get it back"
        showAlert(title: title, message: message)
        showAlert(title: "ALERT", message: "Your Drone left the local region")
        //showNotification(title: title, message: message)
    }
}
/**********************************************************************************************/

extension MAP1ViewController: MKMapViewDelegate {
    func addRadiusCircle(location: CLLocationCoordinate2D){
        self.mapView.delegate = self
        let circle = MKCircle(center: location, radius: radius)
        self.mapView.add(circle)
    }
    
/**********************************************************************************************/
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .red
        circleRenderer.alpha = 0.3
        return circleRenderer
    }
}


