//
//  CourseTableViewCell.swift
//  project
//
//  Created by prk on 13/12/24.
//

import UIKit

protocol CourseTableViewCellDelegate: AnyObject {
    func didChangeQuantity(for cell: CourseTableViewCell, newQuantity: Int)
}

class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseTeacher: UILabel!
    @IBOutlet weak var courseTopic: UILabel!
    
    @IBOutlet weak var courseImg: UIImageView!
    weak var delegate: CourseTableViewCellDelegate?
    private var courseItem: CourseList?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let margin: CGFloat = 5
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true

        layer.cornerRadius = 15
        layer.masksToBounds = false
    }
    
    func configure(with courseItem: CourseList) {
        self.courseItem = courseItem
        courseName.text = courseItem.cname
        courseTeacher.text = courseItem.cteacher
        courseTopic.text = courseItem.ctopic
       
        if let imageUrlString = courseItem.cimage, let url = URL(string: imageUrlString) {
                    courseImg.image = nil // Clear previous image
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            print("Error fetching image: \(error.localizedDescription)")
                            return
                        }
                        guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            print("Invalid response or data")
                            return
                        }
                        DispatchQueue.main.async {
                            if let image = UIImage(data: data) {
                                self.courseImg.image = image
                            }
                        }
                    }.resume()
                } else {
                    // Handle case where imageUrlString is nil or invalid
                    courseImg.image = UIImage(named: "placeholderImage") // Use a placeholder image
                }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
