import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit


class driversVC: UITableViewController,CLLocationManagerDelegate {
    
    var rideRequest: [DataSnapshot] = []
    var locationManger = CLLocationManager()
    var drivreLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        
        Database.database().reference().child("RideRequests").observe(.childAdded, with: { (snapshot) in
            self.rideRequest.append(snapshot)
            self.tableView.reloadData()
            
        })
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rideRequest.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "driverCell", for: indexPath)
        
        let snapshot = rideRequest[indexPath.row]
        
        if let rideRequestDic = snapshot.value as? [String:AnyObject]{
            if let email = rideRequestDic["email"] as? String {
                if let lat = rideRequestDic ["lat"] as? Double {
                    if let lon = rideRequestDic ["lon"] as? Double {
                        
                        let driverclocation = CLLocation(latitude: drivreLocation.latitude, longitude: drivreLocation.longitude)
                        
                        let redierLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = driverclocation.distance(from: redierLocation) / 1000
                        let roudedDestance = round(distance * 100) / 100
                        
                        
                        
                        cell.textLabel?.text = "\(email) - \(roudedDestance) :km away"
                        
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = rideRequest[indexPath.row]
        
        performSegue(withIdentifier: "AcceptSuge", sender: snapshot)
        
    }
    
    
    
    
    @IBAction func logoutBut(_ sender: Any) {
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            drivreLocation = coord
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let accpetVC = segue.destination as? AcceptRideVC {
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDic = snapshot.value as? [String:AnyObject]{
                    if let email = rideRequestDic["email"] as? String {
                        if let lat = rideRequestDic ["lat"] as? Double {
                            if let lon = rideRequestDic ["lon"] as? Double {
                                accpetVC.requesEmail = email
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                accpetVC.requestLocation = location
                                accpetVC.driverlocation = drivreLocation
                            }
                        }
                    }
                }
            }
        }
    }    
}
