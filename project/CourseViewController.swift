//
//  CourseViewController.swift
//  project
//
//  Created by prk on 13/12/24.
//

import UIKit
import CoreData

class CourseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    var courseItems: [CourseList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeContext()
        loadCourseItems()
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCourseItems()
    }

    private func initializeContext() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    private func loadCourseItems() {
        guard let uid = getUID() else {
            print("No current user ID found")
            return
        }
        let currUID = uid.uuidString
        print(currUID)
        fetchCourseItems(for: currUID)
    }
    private func fetchCourseItems(for uid: String) {
        let fetchRequest: NSFetchRequest<CourseList> = CourseList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", uid as CVarArg)

        do {
            courseItems = try context.fetch(fetchRequest)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch cart items: \(error.localizedDescription)")
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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CourseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CourseTableViewCell else {
            fatalError("Failed to dequeue CourseTableViewCell")
        }
        cell.configure(with: courseItems[indexPath.row])
        cell.delegate = self
        cell.layer.cornerRadius = 15
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let courseItem = courseItems[indexPath.row]
        context.delete(courseItem)
        courseItems.remove(at: indexPath.row)

        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Failed to delete course item: \(error.localizedDescription)")
        }
    }
}

extension CourseViewController: CourseTableViewCellDelegate {
    func didChangeQuantity(for cell: CourseTableViewCell, newQuantity: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

//        let courseItem = courseItems[indexPath.row]
//        courseItem.bookquantity = Int16(newQuantity)

        do {
            try context.save()
            tableView.reloadRows(at: [indexPath], with: .none)
        } catch {
            print("Failed to update quantity: \(error.localizedDescription)")
        }
    }
}
