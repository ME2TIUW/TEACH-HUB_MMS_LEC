//
//  ProfileViewController.swift
//  project
//
//  Created by prk on 13/12/24.
//


import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    
    var user: NSManagedObject?
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var userNameLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
        fetchAndDisplayUserData()
    }
    @objc func contextDidChange(notification: Notification) {
            fetchAndDisplayUserData()
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
        }

//    private func fetchAndDisplayData() {
//        guard let user = user else {
//            print("Error: No user data passed to ProfileViewController.")
//            userNameLbl.text = "N/A"
//            courseLbl.text = "0"
//            certifLbl.text = "0"
//            return
//        }
//
//        // Retrieve and display user data
//        let name = user.value(forKey: "name") as? String ?? "N/A"
//        let courses = user.value(forKey: "courseTotal") as? Int32 ?? 0
//        let certif = user.value(forKey: "certifTotal") as? Int32 ?? 0
//
//        userNameLbl.text = "\(name)"
//       
//    }
    
    private func fetchAndDisplayUserData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let currentUserEmail = UserDefaults.standard.string(forKey: "currentUser") ?? ""
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", currentUserEmail)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                let email = user.value(forKey: "email") as? String ?? "N/A"
                userNameLbl.text = email
            }
        } catch {
            print("Error fetching user data: \(error)")
          
        }
    }
    

    @IBAction func signOut(_ sender: Any) {
        performSegue(withIdentifier: "signOutSegue", sender: self)
    }
}
