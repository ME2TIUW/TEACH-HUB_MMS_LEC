

import UIKit
import CoreData


class LoginViewController: UIViewController {
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!

    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
//        let bundleIdentifier = Bundle.main.bundleIdentifier
//        print("Bundle ID:", bundleIdentifier ?? "Bundle ID not found")
    }
    
  func showAlert(
    title: String,
    message: String,
    isSuccess: Bool = false,
    handler: ((UIAlertAction) -> Void)? = nil
  ) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    if isSuccess {
      // Add "Yes" and "No" buttons when it's a success case
      alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: handler))
    } else {
      // Default OK button for error cases
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }

    // Present the alert on the main thread
    if self.isViewLoaded && self.view.window != nil {
      self.present(alert, animated: true, completion: nil)
    } else {
      // If the view is not in the window hierarchy, delay the presentation slightly
      DispatchQueue.main.async {
        self.present(alert, animated: true, completion: nil)
      }
    }
  }

    func validateLogin(email: String, password: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)

        do {
            let results = try context.fetch(request)
            if let user = results.first as? NSManagedObject {
                // Check for admin role
                if let userUsername = user.value(forKey: "email") as? String,
                   userUsername.contains("_admin") {
//                    // Redirect to admin view controller
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let adminVC = storyboard.instantiateViewController(withIdentifier: "loginAdmin") as? AdminViewController{
                            adminVC.modalPresentationStyle = .fullScreen
                            present(adminVC, animated: true, completion: nil)
                        }
                } else {
                    // Redirect to regular user view controller
                    showAlert(title: "Success", message: "Login successful! Proceed to the next page?",
                              isSuccess: true) { [weak self] _ in
                        self?.performSegue(withIdentifier: "loginToHome", sender: user)
                    }
                }
                return user
            } else {
                print("No matching user found in Core Data.")
                return nil
            }
        } catch {
            print("Failed to fetch user data: \(error)")
            return nil
        }
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password." )
            return
        }
        
        if let user = validateLogin(email: email, password: password) {
            UserDefaults.standard.set(email, forKey: "currentUser")
            showAlert(title: "Success", message: "Login successful! Proceed to the next page?",
                      isSuccess: true) {
                [weak self] _ in
                self?.performSegue(withIdentifier: "loginToHome", sender: user)
            }
        } else {
            showAlert(title: "Error", message: "Invalid username or password. Please try again.")
        }
        
    }
        @IBAction func signUpBtn(_ sender: Any) {
            performSegue(withIdentifier: "signUpSegue", sender: self)
        }
    }
    
