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
        }
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.width / 2
        lblDay.textColor = isRecorded ? .bgGreen : .disableGray
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if isSelected {
                backgroundColor = .bgGreen
                lblDay.textColor = .white
            } else {
                backgroundColor = .clear
                lblDay.textColor = isRecorded ? .bgGreen : .disableGray
            }
        }
    }
}
