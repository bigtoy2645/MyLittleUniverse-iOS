//
//  EmotionCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/17.
//

import UIKit

class EmotionCollectionViewCell: UICollectionViewCell {
    static let identifier = "emotionCell"
    
    @IBOutlet weak var lblStatus: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.cgColor
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if self.isSelected {
                lblStatus.textColor = UIColor.bgGreen
                lblStatus.backgroundColor = UIColor.pointPurple
                lblStatus.layer.cornerRadius = lblStatus.frame.width / 2
            } else {
                lblStatus.textColor = .white
                lblStatus.backgroundColor = .clear
                lblStatus.layer.cornerRadius = 0
            }
        }
    }
}
