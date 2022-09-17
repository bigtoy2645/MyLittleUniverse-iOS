//
//  ColorWellCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/09/12.
//

import UIKit

class ColorWellCell: UICollectionViewCell {
    static let identifier = "colorWellCell"
    
    let colorWell = UIColorWell()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        colorWell.selectedColor = UIColor(rgb: 0xFFFFFF)
        self.addSubview(colorWell)
        
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        colorWell.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        colorWell.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        colorWell.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        colorWell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if isSelected {
                layer.borderWidth = 1
                layer.cornerRadius = frame.width / 2
                layer.borderColor = UIColor.black.cgColor
            } else {
                layer.borderWidth = 0
                layer.cornerRadius = 0
            }
        }
    }
}
