import UIKit
import FirebaseAuth

class loginSignUpVC: UIViewController {
    
    
    @IBOutlet weak var driverlable: UILabel!
    @IBOutlet weak var riderLable: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var switchBut: UISwitch!
    @IBOutlet weak var signupBut: UIButton!
    @IBOutlet weak var signinBut: UIButton!
    
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func signupTapped(_ sender: Any) {
        if emailTF.text == "" || passwordTF.text == "" {
            displayAlert(title: "Enter Empty", message: "PLZ Enter Email And Password")
        }else {
            if let email = emailTF.text {
                if let password = passwordTF.text {
                    if signUpMode {
                        // signUp
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil  {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else {
                                print("Seccess")
                             self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        })
                    }else {
                        //Login
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil  {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else {
                                print("Seccess")
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    @IBAction func signinTapped(_ sender: Any) {
        if signUpMode {
            signupBut.setTitle("Sign In", for: .normal)
            signinBut.setTitle("Sign Up", for: .normal)
            riderLable.isHidden = true
            driverlable.isHidden = true
            switchBut.isHidden = true
            signUpMode = false
        }else {
            signupBut.setTitle("Sign Up", for: .normal)
            signinBut.setTitle("Sign In", for: .normal)
            riderLable.isHidden = false
            driverlable.isHidden = false
            switchBut.isHidden = false
            signUpMode = true
        }
    }
    
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

