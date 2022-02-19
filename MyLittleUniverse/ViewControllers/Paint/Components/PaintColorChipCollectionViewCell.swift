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
