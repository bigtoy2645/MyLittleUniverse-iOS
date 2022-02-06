//
//  TodayCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/17.
//

import UIKit

class TodayCollectionViewCell: UICollectionViewCell {
    static let identifier = "todayCell"
    
    @IBOutlet weak var lblStatus: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if self.isSelected {
                lblStatus.textColor = UIColor.bgGreen
                backgroundColor = UIColor.pointPurple
                layer.borderWidth = 0
                layer.cornerRadius = contentView.frame.width / 2
            } else {
                lblStatus.textColor = .white
                backgroundColor = .clear
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 1
                layer.cornerRadius = 0
            }
        }
    }
}
