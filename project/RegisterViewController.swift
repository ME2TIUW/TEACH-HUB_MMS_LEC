//
//  RegisterViewController.swift
//  GrameJiaBook
//
//  Created by prk on 12/2/24.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController, UITextFieldDelegate{

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
        
        
//        appDelegate.deleteAllData(forEntityName: "Course")
//        appDelegate.deleteAllData(forEntityName: "Cart")
//        appDelegate.deleteAllData(forEntityName: "History")
        loadData()
//        printData()
    

    }
    
//    func printData() {
//        print("Saved Accounts")
//        for (index, userName) in arrName.enumerated(){
//            let password = arrPass[index]
//            let userId = arrId[index]
//            print("User \(index + 1): Username: \(userName), Password: \(password), userId : \(userId)")
//        }
//    }
    
    func saveData(){
        
        guard let userName = nameTF.text, !userName.isEmpty, let password = passTF.text, !password.isEmpty, let email = emailTF.text, !email.isEmpty else {
            print("Username, email, or password can't be empty")
            return
        }
        
        guard !isDuplicateUsername(userName) else {
                showAlert(title: "Error", message: "Username already taken. Please choose another username.")
                return
            }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            print("Failed to retrieve register entity")
            return
        }
        
        let newUser = NSManagedObject(entity: entity, insertInto: context)
        
        let getId = generateID()
        UserDefaults.standard.set(getId.uuidString, forKey: "currId")
        
        newUser.setValue(getId, forKey: "userId")
        newUser.setValue(userName, forKey: "name")
        newUser.setValue(password, forKey: "password")
        newUser.setValue(email, forKey: "email")
      
        
        do{
            try context.save()
            print("Data saved successfully")
            loadData()
//            printData()
        }catch let error as NSError{
            print("Save Failed")
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
    
    func generateID() -> UUID{
        return UUID()
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
            saveData()
//            printData()
        
            showAlert(
                title: "Success",
                message: "Account Created, ",
                        isSuccess: true
            ) { [weak self] _ in
                    self?.performSegue(withIdentifier: "afterRegis", sender: nil)
            }
        } else {
            showAlert(title: "Error", message: validation.message ?? "Unknown error occurred")
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
