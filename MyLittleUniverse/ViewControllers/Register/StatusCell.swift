//
//  EmotionCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/17.
//

import UIKit

class StatusCell: UICollectionViewCell {
    static let identifier = "statusCell"
    
    @IBOutlet weak var lblStatus: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.bgGreen70.cgColor
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if self.isSelected {
                lblStatus.textColor = UIColor.bgGreen
                lblStatus.backgroundColor = UIColor.pointPurple
                lblStatus.layer.cornerRadius = lblStatus.frame.width / 2
                layer.borderWidth = 0
            } else {
                lblStatus.textColor = .white
                lblStatus.backgroundColor = .clear
                lblStatus.layer.cornerRadius = 0
                layer.borderWidth = 0.5
            }
        }
    }
}
