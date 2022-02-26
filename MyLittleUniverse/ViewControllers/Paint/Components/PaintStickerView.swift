//
//  PaintStickerView.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/27.
//

import UIKit

class PaintStickerView: UIView {
    
    @IBOutlet weak var btnLeftTop: UIButton!
    @IBOutlet weak var btnRightTop: UIButton!
    @IBOutlet weak var btnLeftBottom: UIButton!
    @IBOutlet weak var btnRightBottom: UIButton!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var stickerView: UIView!
    
    var isSelected = false {
        didSet {
            borderView.layer.borderWidth = isSelected ? 1 : 0
            btnLeftTop.isHidden = !isSelected
            btnRightTop.isHidden = !isSelected
            btnLeftBottom.isHidden = !isSelected
            btnRightBottom.isHidden = !isSelected
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadXib()
    }
    
    private func loadXib() {
        if let view = Bundle.main.loadNibNamed("PaintStickerView",
                                               owner: self,
                                               options: nil)?.first as? UIView {
            view.frame = self.bounds
            addSubview(view)
            
            borderView.layer.borderColor = UIColor.white.cgColor
        }
    }
}
