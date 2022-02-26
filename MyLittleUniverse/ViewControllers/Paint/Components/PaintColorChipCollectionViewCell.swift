//
//  PaintColorChipCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/05.
//

import UIKit

class PaintColorChipCollectionViewCell: UICollectionViewCell {
    static let identifier = "colorChipCell"
    
    @IBOutlet weak var imgCircle: UIImageView!
    var hexColor: Int = 0xFFFFFF {
        didSet {
            let imgName = hexColor == 0xFFFFFF ? "CircleLine" : "Circle"
            imgCircle.image = UIImage(named: imgName)
            imgCircle.tintColor = UIColor(rgb: hexColor)
        }
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if self.isSelected {
                layer.borderWidth = 1
                layer.cornerRadius = contentView.frame.width / 2
                layer.borderColor = UIColor.black.cgColor
            } else {
                layer.borderWidth = 0
                layer.cornerRadius = 0
            }
        }
    }
}
