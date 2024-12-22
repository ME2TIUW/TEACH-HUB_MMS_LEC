//
//  DetailCourseViewController.swift
//  project
//
//  Created by Nicholas Matthew on 20/12/24.
//

import UIKit
import CoreData

class DetailCourseViewController: UIViewController {

    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailName: UILabel!
    @IBOutlet weak var detailTeacher: UILabel!
    @IBOutlet weak var detailDesc: UILabel!
    @IBOutlet weak var detaiTopic: UILabel!
    
    var detImage: String?
    var detName: String?
    var detTeacher: String?
    var detDesc: String?
    var detTopic:String?
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailName.text = detName
        detailTeacher.text = detTeacher
        detailDesc.text = detDesc
        detaiTopic.text = detTopic
        if let detImgUrl = detImage, let url = URL(string: detImgUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed load image \(error.localizedDescription)")
                    return
                }
                guard let data = data, let img = UIImage(data: data) else {
                    print("Failed to get image")
                    return
                }
                DispatchQueue.main.async {
                    self.detailImage.image = img
                }
            }.resume()
        } else {
            print("Invalid url \(detImage ?? "nil")")
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    

  
    @IBAction func backButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "backToHome", sender: self)
    }
 
    
    @IBAction func playlistButtonTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Enroll Course", message: "Are you sure want to enroll this course?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_) in
            self.addToCourses()
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Course")
                    fetchRequest.predicate = NSPredicate(format: "cname == %@", self.detName ?? "")
            
            do {
                let result = try self.context.fetch(fetchRequest)
                if let courseExist = result.first {
                    if let videoLink = courseExist.value(forKey: "cvideo") as? String,
                        let url = URL(string: videoLink), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                    } else {
                        print("Invalid YouTube link or URL")
                    }
                }
            } catch {
                print("Failed to fetch course: \(error.localizedDescription)")
            }
            
            let success = UIAlertController(
                title: "Success", message: "Course enrolled", preferredStyle: .alert)
            success.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(success, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
//        performSegue(withIdentifier: "", sender: self)
    }
    private func addToCourses(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CourseList")
        fetchRequest.predicate = NSPredicate(format: "cname == %@", detName ?? "")
        
        do {
            let result = try context.fetch(fetchRequest)
            if let courseExist = result.first{
                let alert = UIAlertController(
                    title: "Warning", message: "Course already enrolled", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                print(courseExist.value(forKey: "cname"))
                print(courseExist.value(forKey: "ctopic"))
                print(courseExist.value(forKey: "cteacher"))
            } else {
                guard let entity = NSEntityDescription.entity(forEntityName: "CourseList", in: context) else {
                    print("Failed create entity")
                    return
                }
                let newCourse = NSManagedObject(entity: entity, insertInto: context)
                newCourse.setValue(detName, forKey: "cname")
                newCourse.setValue(detImage, forKey: "cimage")
                newCourse.setValue(detTeacher, forKey: "cteacher")
                newCourse.setValue(detTopic, forKey: "ctopic")
                newCourse.setValue(detImage,forKey: "cimage")
                
                if let uid = getUID(){
                    newCourse.setValue(uid, forKey: "userId")
                } else {
                    print("Invalid userId")
                }
            }
            try context.save()
            print("Course saved")
        } catch {
            print("Failed save course \(error.localizedDescription)")
        }
    }
    
    private func getUID() -> UUID? {
        guard let email = UserDefaults.standard.string(forKey: "currentUser") else {
            return nil
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            if let user = try context.fetch(fetchRequest).first {
                return user.value(forKey: "userId") as? UUID
            }
        } catch {
            print("Failed to fetch user: \(error.localizedDescription)")
        }
        return nil
    }
}
