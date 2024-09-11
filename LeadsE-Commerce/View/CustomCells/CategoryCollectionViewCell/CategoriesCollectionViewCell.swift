//
//  CategoriesCollectionViewCell.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //koseleri yuvarlaklastirma
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
}
