//
//  PaintStickerCollectionViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/13.
//

import UIKit

class ShapeStickerCell: UICollectionViewCell {
    static let identifier = "shapeStickerCell"
    
    @IBOutlet weak var sticker: UIImageView!
    
    override func layoutSubviews() {
        sticker.contentMode = .scaleAspectFit
        self.tintColor = UIColor(rgb: 0xC4C4C4)
    }
}
