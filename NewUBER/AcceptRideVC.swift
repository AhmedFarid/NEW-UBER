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
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requesEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                    
                    
                }
            }
        }
    }
}
