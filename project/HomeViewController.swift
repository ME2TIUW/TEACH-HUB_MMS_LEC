import UIKit
import CoreData

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var currentCourse = 0
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var courseCollection: UICollectionView!
    
    var course: [Course] = []
    var segmentedItem: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        homeCollection.tag = 1
//        bookCollection.tag = 2
        
        let courseLayout = UICollectionViewFlowLayout()
        courseLayout.scrollDirection = .vertical
        courseLayout.itemSize = CGSize(width: 361, height: 317)
        courseLayout.minimumLineSpacing = 10
        courseCollection.collectionViewLayout = courseLayout
        courseCollection.dataSource = self
        courseCollection.delegate = self
        
//        let homeLayout = UICollectionViewFlowLayout()
//        homeLayout.scrollDirection = .horizontal
//        homeLayout.itemSize = CGSize(width: 361, height: 174)
//        homeLayout.minimumLineSpacing = 0
//        homeCollection.collectionViewLayout = homeLayout
//        homeCollection.isPagingEnabled = true
//        homeCollection.showsHorizontalScrollIndicator = false
//        homeCollection.dataSource = self
//        homeCollection.delegate = self
        
        fetchItem()
        segmentItem()
        
        let currUser = UserDefaults.standard.string(forKey: "currentUser")
        nameLbl.text = currUser
    }
    
    
    @IBAction func segmentChange(_ sender: Any) {
        segmentItem()
        courseCollection.reloadData()
    }
    
    func segmentItem(){
        let selectedSegment = segment.selectedSegmentIndex
        
        switch selectedSegment{
        case 0:
            segmentedItem = course
        case 1:
            segmentedItem = course.filter{$0.ctopic == "Business"}
        case 2:
            segmentedItem = course.filter{$0.ctopic == "Economy"}
        case 3:
            segmentedItem = course.filter{$0.ctopic == "Computer"}
        case 4:
            segmentedItem = course.filter{$0.ctopic == "Science"}
        default:
            segmentedItem = course
        }
    }
    
    func fetchItem(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Course>(entityName: "Course")
        
        do {
            course = try context.fetch(fetchRequest)
            courseCollection.reloadData()
        } catch {
            print("Failed to fetch items \(error.localizedDescription)")
        }
    }
    
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return segmentedItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeCollectionViewCell
        
        
        let item = segmentedItem[indexPath.row]
        if let imageUrl = item.cimage, let url = URL(string: imageUrl){
            URLSession.shared.dataTask(with: url){ data, _, _ in
                if let data = data, let image = UIImage(data: data){
                    DispatchQueue.main.async{
                        if let currCell = collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell {
                            currCell.cImage.image = image
                        }
                    }
                }
            } .resume()
        } else {
            cell.cImage.image = UIImage(named: "placeHolder")
        }
        cell.cName.text = item.cname
        cell.cTeacher.text = item.cteacher
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard collectionView.tag == 2 else {return}
        let item = segmentedItem[indexPath.row]
        let detail = self.storyboard?.instantiateViewController(withIdentifier: "DetailPage") as! DetailCourseViewController
        
        detail.detImage = item.cimage
        detail.detName = item.cname
        detail.detTeacher = item.cteacher
        detail.detTopic = item.ctopic
        detail.detDesc = item.cdesc
        
       
        self.present(detail, animated: true, completion: nil)
    }
    
    
    
}

//extension UIImageView {
//    func loadImage(from urlString: String?, placeholder: String = "placeHolder") {
//        guard let urlString = urlString, let url = URL(string: urlString) else {
//            self.image = UIImage(named: placeholder)
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.image = image
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.image = UIImage(named: placeholder)
//                }
//            }
//        }.resume()
//    }
//}

