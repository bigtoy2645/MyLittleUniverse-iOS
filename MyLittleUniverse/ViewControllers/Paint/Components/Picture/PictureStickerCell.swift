//
//  PictureStickerCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit

class PictureStickerCell: UICollectionViewCell {
    static let identifier = "pictureStickerCell"
    
    @IBOutlet weak var sticker: UIImageView!
    
    override func layoutSubviews() {
        sticker.contentMode = .scaleAspectFill
    }
}
