//
//  PaintStickerView.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/27.
//

import UIKit
import RxSwift
import RxCocoa

class PaintStickerView: UIView {
    let sticker = BehaviorRelay<Sticker>(value: Sticker())
    var disposeBag = DisposeBag()
    
    var stickerView: UIView? {
        didSet {
            guard let stickerView = stickerView,
                  !borderView.contains(stickerView) else { return }
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
        guard let view = Bundle.main.loadNibNamed("PaintStickerView",
                                                  owner: self,
                                                  options: nil)?.first as? UIView else { return }
        view.frame = self.bounds
        addSubview(view)
        
        borderView.layer.borderColor = UIColor.white.cgColor
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        // 이미지 스티커
        sticker.asObservable()
            .map { ($0.image, $0.hexColor) }
            .observe(on: MainScheduler.instance)
            .bind { image, hexColor in
                guard let image = image else { return }
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = UIColor(rgb: hexColor)
                self.stickerView = imageView
            }
            .disposed(by: disposeBag)
        
        // 텍스트 스티커
        sticker.asObservable()
            .map { $0.text }
            .observe(on: MainScheduler.instance)
            .bind { text in
                guard let text = text else { return }
                if let labelView = self.stickerView as? UILabel {
                    labelView.text = text
                    labelView.sizeToFit()
                } else {
                    let lblText = UILabel()
                    lblText.text = text
                    lblText.textAlignment = .center
                    lblText.lineBreakMode = .byClipping
                    self.stickerView = lblText
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var btnLeftTop: UIButton!
    @IBOutlet weak var btnRightTop: UIButton!
    @IBOutlet weak var btnLeftBottom: UIButton!
    @IBOutlet weak var btnRightBottom: UIButton!
    
    @IBOutlet weak var borderView: UIView!
}
