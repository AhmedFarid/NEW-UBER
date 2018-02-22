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
                    
                })
        
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            mapKit.setRegion(region, animated: true)
            
            mapKit.removeAnnotations(mapKit.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "YOU"
            mapKit.addAnnotation(annotation)
        }
    }
    
    
    
    @IBAction func logoutBut(_ sender: Any) {
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
        
        
    }
    @IBAction func callUberTabed(_ sender: Any) {
        
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
