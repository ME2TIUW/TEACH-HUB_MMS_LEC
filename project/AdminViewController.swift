//
//  AdminViewController.swift
//  GrameJiaBook_CoreApp
//
//  Created by prk on 17/12/24.
//

import UIKit
import CoreData

class AdminViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addAdminViewControllerDelegate {

    
    @IBOutlet weak var adminTableView: UITableView!
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "adminToLogin", sender: self)
    }
    
    var context: NSManagedObjectContext!
    var arrObjects = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adminTableView.dataSource = self
        adminTableView.delegate = self
        
        let appdel = UIApplication.shared.delegate as! AppDelegate
        context = appdel.persistentContainer.viewContext
        loaddata()
        
//        appdel.deleteAllData(forEntityName: "Course")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loaddata()
    }
    
    func loaddata() {
        let req = NSFetchRequest<Course>(entityName: "Course")
        arrObjects.removeAll()
        do {
            arrObjects = try context.fetch(req)
            adminTableView.reloadData()
        } catch {
            print("Failed to fetch Courses: \(error.localizedDescription)")
        }
    }
    
    func didAddProduct() {
        loaddata()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrObjects.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! addAdminTableViewCell
        
        let course = arrObjects[indexPath.row]
        cell.courseTitle.text = course.cname
        cell.courseTeacher.text = course.cteacher

       
        if let imageUrlString = course.cimage, let url = URL(string: imageUrlString) {
            
            cell.courseImg.image = nil
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching image: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response or data")
                    return
                }
                
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        
                        if let currentCell = tableView.cellForRow(at: indexPath) as? addAdminTableViewCell {
                            currentCell.courseImg.image = image
                        }
                    }
                }
            }.resume()
        }
        
        return cell
    }

    
    func didUpdateProduct() {
        loaddata()
    }
    //
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                let objectToDelete = self.arrObjects[indexPath.row]
                
                self.context.delete(objectToDelete)
                do {
                    try self.context.save()
                    self.loaddata()
                } catch {
                    print("Failed to delete product: \(error.localizedDescription)")
                }
                
                completionHandler(true)
            }
            
            deleteAction.backgroundColor = .red
            let configuration = UISwipeActionsConfiguration(actions: [ deleteAction])
            return configuration
        }
    @IBAction func unwindToAdmin(_ unwindSegue: UIStoryboardSegue) {
        
        // Use data from the view controller which initiated the unwind segue
    }
    }
