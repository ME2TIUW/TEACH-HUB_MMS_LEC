import UIKit
import CoreData
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var nameTF: UITextField!
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var cfrmPassTF: UITextField!
  @IBOutlet weak var passTF: UITextField!
  var context: NSManagedObjectContext!
    
    var arrName = [String]()
    var arrPass = [String]()
    var arrEmail = [String]()
    var arrId = [UUID]()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupDelegates()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    context = appDelegate.persistentContainer.viewContext
  }

    func isDuplicateUsername(_ userName: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "name == %@", userName)
        
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            print("Failed to check duplicate username: \(error)")
            return false
        }
    }
    
  private func setupDelegates() {
    nameTF.delegate = self
    passTF.delegate = self
    cfrmPassTF.delegate = self
    emailTF.delegate = self
  }

  func validateFields() -> (isValid: Bool, message: String?) {
      guard let nameText = nameTF?.text, !nameText.isEmpty else {
          return (false, "Please enter username")
      }
      
      guard let passwordText = passTF?.text, !passwordText.isEmpty else {
          return (false, "Please enter password")
      }
      
      guard let confirmText = cfrmPassTF?.text, !confirmText.isEmpty else {
          return (false, "Please confirm your password")
      }
      
      if nameText.count < 3 {
          return (false, "Username must be at least 3 characters long")
      }
      
      if passwordText.count < 6 {
          return (false, "Password must be at least 6 characters long")
      }
      
      if passwordText != confirmText {
          return (false, "Passwords do not match")
      }
      
      if isDuplicateUsername(nameText) {
              return (false, "Username already exists. Please choose a different one.")
      }
      
      return (true, nil)
  }

    private func showAlert(
        title: String,
        message: String,
        isSuccess: Bool = false,
        animated: Bool = true,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if isSuccess {
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: handler))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: animated)
        }
    }
    
  

  @IBAction func regisBtn(_ sender: Any) {
    let validation = validateFields()

    if validation.isValid {
      guard let email = emailTF.text, let password = passTF.text, let username = nameTF.text else { return }

      // Firebase Authentication - Create User
      Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
        if let error = error {
          self?.showAlert(title: "Error", message: error.localizedDescription)
          return
        }

          guard let userIdString = authResult?.user.uid else { return }
          print("Firebase UID String:", userIdString)
          self!.printData()
          // Convert Firebase UID (NSString) to UUID
         
        // Firestore - Save User Data (modified to exclude password)
        let db = Firestore.firestore()
        db.collection("users").document(userIdString).setData([
          "username": username,
          "email": email,
          "userId": userIdString,
        ]) { error in
          if let error = error {
            self?.showAlert(title: "Error", message: error.localizedDescription)
            return
          }

          // Core Data - Save User Data (after successful Firestore registration)
            self?.saveUserToCoreData(userId: userIdString, username: username, email: email, password: password)
        }
      }
    } else {
      showAlert(title: "Error", message: validation.message ?? "Unknown error occurred")
    }
  }

    private func saveUserToCoreData(userId: String, username: String, email: String, password :String) {
    guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
      print("Failed to retrieve register entity")
      return
    }

    let newUser = NSManagedObject(entity: entity, insertInto: context)
      
      print("username = \(username)")
      print("email = =\(email)")
  
    newUser.setValue(userId, forKey: "userId")
    newUser.setValue(username, forKey: "name")
    newUser.setValue(email, forKey: "email")
      newUser.setValue(password, forKey: "password")

    do {
      try context.save()
      print("Data saved successfully to Core Data")
    showAlert(title: "Success", message: "Account created successfully.", isSuccess: true)
    { _ in
        self.performSegue(withIdentifier: "afterRegis", sender: nil)
        self.loadData()
        self.printData()
      }
    } catch let error as NSError {
      print("Save Failed to Core Data: \(error)")
    }
  }
    
    func loadData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        arrName.removeAll()
        arrPass.removeAll()
        arrId.removeAll()

        do{
            let results = try context.fetch(request) as! [NSManagedObject]
                        
            for data in results{
                if let username = data.value(forKey: "name") as? String,
                   let password = data.value(forKey: "password") as? String{
                    arrName.append(username)
                    arrPass.append(password)
                }
                
                if let userId = data.value(forKey: "userId") as? UUID{
                    arrId.append(userId)
                }else{
                    print("error")
                }
                        }
        }
        catch{
            print("failed fetch data")
        }
    }
    
        func printData() {
            print("Saved Accounts")
            for (index, userName) in arrName.enumerated(){
                let password = arrPass[index]
                let userId = arrId[index]
                print("User \(index + 1): Username: \(userName), Password: \(password), userId : \(userId)")
            }
        }
    

    @IBAction func signInBtn(_ sender: Any) {
        performSegue(withIdentifier: "signInSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backtoLogin" {
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "backtoLogin" {
            let validation = validateFields()
            if !validation.isValid {
                showAlert(title: "Error", message: validation.message ?? "Validation failed")
                return false
            }
        }
        return true
    }
}
