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
    
    var stickerView: UIView? {
        didSet {
            guard let stickerView = stickerView else { return }
            DispatchQueue.main.async {
                self.borderView.addSubview(stickerView)
                stickerView.translatesAutoresizingMaskIntoConstraints = false
                stickerView.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 4).isActive = true
                stickerView.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -4).isActive = true
                stickerView.leftAnchor.constraint(equalTo: self.borderView.leftAnchor, constant: 4).isActive = true
                stickerView.rightAnchor.constraint(equalTo: self.borderView.rightAnchor, constant: -4).isActive = true
            }
        }
    }
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
