import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class ridersVC: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var callUberBut: UIButton!
    
    var locationManger = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverLocation = CLLocationCoordinate2D()
    var driverOnTheWay = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email{
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberHasBeenCalled = true
                self.callUberBut.setTitle("Cancel UBER", for: .normal)
                
                
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let riderRequestDiec = snapshot.value as? [String:AnyObject] {
                    if let driverLat = riderRequestDiec["driverLat"] as? Double {
                        if let driverLon = riderRequestDiec["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            
                        }
                    }
                }
                
            })
            
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roudedDestance = round(distance * 100) / 100
        callUberBut.setTitle("Your Driver \(roudedDestance)Km Away", for: .normal)
        mapKit.removeAnnotations(mapKit.annotations)
        let latDelata = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelata = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelata, longitudeDelta: lonDelata))
        mapKit.setRegion(region, animated: true)
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "You "
        mapKit.addAnnotation(riderAnno)
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Driver"
        mapKit.addAnnotation(driverAnno)
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            
            if uberHasBeenCalled {
                displayDriverAndRider()
            }else {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                mapKit.setRegion(region, animated: true)
                
                mapKit.removeAnnotations(mapKit.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "YOU"
                mapKit.addAnnotation(annotation)
            }
        }
    }
    
    
    
    @IBAction func logoutBut(_ sender: Any) {
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
        
        
    }
    @IBAction func callUberTabed(_ sender: Any) {
        if !driverOnTheWay {
            
            if let email = Auth.auth().currentUser?.email{
                
                
                if uberHasBeenCalled {
                    
                    uberHasBeenCalled = false
                    callUberBut.setTitle("Call an Uber", for: .normal)
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                        snapshot.ref.removeValue()
                        Database.database().reference().child("RideRequests").removeAllObservers()
                        
                        
                    })
                    
                }else {
                    let riderRequestDictionary :[String:Any] = ["email":email,"lat":userLocation.latitude,"lon":userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(riderRequestDictionary)
                    
                    uberHasBeenCalled = true
                    callUberBut.setTitle("Cancel UBER", for: .normal)
                }
            }
        }
        
    }
}
