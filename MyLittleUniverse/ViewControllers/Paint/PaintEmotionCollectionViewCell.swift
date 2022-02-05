//
//  PaintEmotionCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/05.
//

import UIKit

class PaintEmotionCollectionViewCell: UICollectionViewCell {
    static let identifier = "paintEmotionCell"
    
    @IBOutlet weak var lblEmotion: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.borderWidth = 1
        layer.cornerRadius = 15
        layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if self.isSelected {
                self.lblEmotion.textColor = .white
                self.layer.borderColor = UIColor.white.cgColor
            } else {
                self.lblEmotion.textColor = UIColor.white.withAlphaComponent(0.5)
                self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            }
        }
    }
}
