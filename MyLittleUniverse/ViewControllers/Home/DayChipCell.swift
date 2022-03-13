//
//  DayCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit

class DayChipCell: UICollectionViewCell {
    static let identifier = "dayChipCell"
    
    @IBOutlet weak var lblDay: UILabel!
    
    var isRecorded = false {
        didSet {
            isUserInteractionEnabled = isRecorded
            layer.borderWidth = isRecorded ? 1 : 0
        }
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.bgGreen?.cgColor
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if isSelected {
                backgroundColor = UIColor.bgGreen
                layer.borderWidth = 0
                lblDay.textColor = .white
            } else {
                backgroundColor = .clear
                layer.borderWidth = isRecorded ? 1 : 0
                lblDay.textColor = UIColor.bgGreen
            }
        }
    }
}
