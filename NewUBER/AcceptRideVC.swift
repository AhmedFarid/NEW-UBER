import UIKit
import MapKit
import FirebaseDatabase

class AcceptRideVC: UIViewController {

    @IBOutlet weak var Accept: UIButton!
    @IBOutlet weak var Map: MKMapView!
    
    
    var requestLocation = CLLocationCoordinate2D()
    var driverlocation = CLLocationCoordinate2D()
    var requesEmail = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        Map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requesEmail
        Map.addAnnotation(annotation)
        
        
        
        
        
    }
    
    
    @IBAction func AcceptBUt(_ sender: Any) {
        
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requesEmail).observe(.childAdded, with: { (snapshot) in
          snapshot.ref.updateChildValues(["driverLat":self.driverlocation.latitude, "driverLon":self.driverlocation.longitude
            ])
            Database.database().reference().child("RideRequests").removeAllObservers()
        })
        
        
        
        
        
    }
}
