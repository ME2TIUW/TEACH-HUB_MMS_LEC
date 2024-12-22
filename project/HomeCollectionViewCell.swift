//
//  HomeCollectionViewCell.swift
//  project
//
//  Created by prk on 12/11/24.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cImage: UIImageView!
    @IBOutlet weak var cName: UILabel!
    @IBOutlet weak var cTeacher: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .white
        cName.textColor = .black
        cTeacher.textColor = .black
        cImage.contentMode = .scaleAspectFill
        cImage.clipsToBounds = true
        cImage.layer.cornerRadius = 10
        cImage.layer.masksToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        cImage.image = UIImage(named: "placeHolder") // Reset gambar
    }
    
}


