//
//  addAdminTableViewCell.swift
//  project
//
//  Created by prk on 20/12/24.
//

import UIKit

class addAdminTableViewCell: UITableViewCell {
    
    
   
    @IBOutlet weak var courseImg: UIImageView!
    
    @IBOutlet weak var courseTitle: UILabel!
    
    @IBOutlet weak var courseTeacher: UILabel!
    
    var onUpdateHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
