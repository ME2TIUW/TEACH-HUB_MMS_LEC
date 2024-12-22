//
//  HomeTableViewCell.swift
//  project
//
//  Created by prk on 12/11/24.
//

import UIKit
import CoreData

class HomeTableViewCell: UITableViewCell, HomeTableViewCellDelegate {
    func didSelectCourse(course: Course) {
            if let viewController = self.superview?.superview as? UIViewController {
                viewController.performSegue(withIdentifier: "navigateToDetails", sender: course)
            }
        }
    
    
    private let sectionTitles = ["Top Course", "New Course"]
    @IBOutlet weak var collectionView: UICollectionView!
    var courses: [Course] = []
    
        func configure(with courses: [Course]) {
            self.courses = courses
            collectionView.reloadData()
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func courseSelected(for course: Course) {
           // Save course name to UserDefaults
        

           // Perform segue with identifier "navigateToDetails" and pass the course as sender
           if let viewController = self.superview?.superview as? UIViewController {
               viewController.performSegue(withIdentifier: "navigateToDetails", sender: course)
           }
       }
    
}


protocol HomeTableViewCellDelegate: AnyObject {
    func didSelectCourse(course: Course)
}


extension HomeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        let course = courses[indexPath.row]
        
        cell.cName.text = course.cname
        cell.cTeacher.text = course.cteacher
//        cell.cContinueBtn.setTitle(course.cprogress == 0 ? "Enroll" : "Continue", for: .normal)
        
//        cell.parentCell = self
//        cell.delegate = self
//        cell.cContinueBtnTapped(cell.cContinueBtn)
//        DispatchQueue.main.async {
//               cell.parentCell = self
//           }
       
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        courses.count
    }
    
  
  
    
}
