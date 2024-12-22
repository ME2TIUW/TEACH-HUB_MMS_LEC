//
//  addAdminViewController.swift
//  project
//
//  Created by prk on 20/12/24.
//

import UIKit
import CoreData

protocol addAdminViewControllerDelegate: AnyObject {
    func didAddProduct()
}



class addAdminViewController: UIViewController {

    @IBOutlet weak var courseTopic: UITextField!
    @IBOutlet weak var courseDesc: UITextField!
    @IBOutlet weak var courseVideo: UITextField!
    @IBOutlet weak var courseImage: UITextField!
    @IBOutlet weak var courseTeacher: UITextField!
    @IBOutlet weak var courseTitle: UITextField!
    
    let segment = ["Business", "Economy", "Computer", "Science"]
    
    @IBAction func addBtnTapped(_ sender: Any) {
        saveProduct()
        dismiss(animated: true) {
        
        self.delegate?.didAddProduct()
        }
    }
    
    var context: NSManagedObjectContext!
    
    weak var delegate: addAdminViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
    }
    
    func saveProduct() {
        let courseTitle = courseTitle.text ?? ""
        let courseTeacher = courseTeacher.text ?? ""
        let courseVideo = courseVideo.text ?? ""
        let courseTopic = courseTopic.text ?? ""
        
        let courseImage = courseImage.text ?? ""
        let courseDesc = courseDesc.text ?? ""
        
      
        let id = generateID()
        
        let entity = NSEntityDescription.entity(forEntityName: "Course", in: context)
        let new = NSManagedObject(entity: entity!, insertInto: context)
        new.setValue(courseTitle, forKey: "cname")
        new.setValue(courseTeacher, forKey: "cteacher")
        new.setValue(courseTopic, forKey: "ctopic")
        new.setValue(courseImage, forKey: "cimage")
        new.setValue(courseDesc, forKey: "cdesc")
        new.setValue(courseVideo, forKey: "cvideo")
        new.setValue(id, forKey: "cid")
        
        do {
            try context.save()
            print("Product saved successfully!")
        } catch {
            print("Save failed: \(error.localizedDescription)")
        }
    }
    
    func generateID() -> UUID {
        return UUID()
    }
}
