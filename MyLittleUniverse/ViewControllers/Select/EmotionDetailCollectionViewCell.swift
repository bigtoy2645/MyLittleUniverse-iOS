//
//  EmotionDetailCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/20.
//

import UIKit

class EmotionDetailCollectionViewCell: UICollectionViewCell {
    static let identifier = "emotionDetailCell"
    
    @IBOutlet weak var lblStatus: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.bgGreen?.cgColor
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if self.isSelected {
                lblStatus.textColor = .pointPurple
                lblStatus.backgroundColor = .bgGreen
                lblStatus.layer.cornerRadius = lblStatus.frame.width / 2
            } else {
                lblStatus.textColor = .bgGreen
                lblStatus.backgroundColor = .clear
                lblStatus.layer.cornerRadius = 0
            }
        }
    }
}
