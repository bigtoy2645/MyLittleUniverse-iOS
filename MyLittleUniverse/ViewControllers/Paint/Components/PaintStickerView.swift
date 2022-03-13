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
    
    enum ButtonPosition {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }
    
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
            btnLeftTop.isHidden = btnLeftTop.isEnabled ? !isSelected : true
            btnRightTop.isHidden = btnRightTop.isEnabled ? !isSelected : true
            btnLeftBottom.isHidden = btnLeftBottom.isEnabled ? !isSelected : true
            btnRightBottom.isHidden = btnRightBottom.isEnabled ? !isSelected : true
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
            .map { ($0.image, $0.hexColor, $0.contentMode) }
            .observe(on: MainScheduler.instance)
            .bind { image, hexColor, contentMode in
                guard let image = image else { return }
                if let imageView = self.stickerView as? UIImageView {
                    imageView.image = image
                    imageView.tintColor = UIColor(rgb: hexColor)
                } else {
                    let imageView = UIImageView()
                    imageView.contentMode = contentMode
                    imageView.clipsToBounds = true
                    imageView.tintColor = UIColor(rgb: hexColor)
                    imageView.image = image
                    self.stickerView = imageView
                }
            }
            .disposed(by: disposeBag)
        
        // 텍스트 스티커
        sticker.asObservable()
            .map { ($0.text, $0.hexColor) }
            .observe(on: MainScheduler.instance)
            .bind { text, hexColor in
                guard let text = text else { return }
                if let labelView = self.stickerView as? UILabel {
                    labelView.text = text
                    labelView.textColor = UIColor(rgb: hexColor)
                    labelView.sizeToFit()
                } else {
                    let lblText = UILabel()
                    lblText.text = text
                    lblText.textColor = .black
                    lblText.textAlignment = .center
                    lblText.lineBreakMode = .byClipping
                    self.stickerView = lblText
                }
            }
            .disposed(by: disposeBag)
    }
    
    /* 좌상단 버튼 */
    func setLeftTopButton(image: UIImage? = nil, tapEvent: @escaping () -> ()) {
        btnLeftTop.isEnabled = true
        if let image = image { btnLeftTop.setImage(image, for: .normal) }
        btnLeftTop.rx.tap
            .bind {
                tapEvent()
            }
            .disposed(by: disposeBag)
    }
    
    /* 좌하단 버튼 */
    func setLeftBottomButton(image: UIImage? = nil, tapEvent: @escaping () -> ()) {
        btnLeftBottom.isEnabled = true
        if let image = image { btnLeftBottom.setImage(image, for: .normal) }
        btnLeftBottom.rx.tap
            .bind {
                tapEvent()
            }
            .disposed(by: disposeBag)
    }
    
    /* 우상단 버튼 */
    func setRightTopButton(image: UIImage? = nil, tapEvent: @escaping () -> ()) {
        btnRightTop.isEnabled = true
        if let image = image { btnRightTop.setImage(image, for: .normal) }
        btnRightTop.rx.tap
            .bind {
                tapEvent()
            }
            .disposed(by: disposeBag)
    }
    
    /* 우하단 버튼 */
    func setRightBottomButton(image: UIImage? = nil, tapEvent: @escaping () -> ()) {
        btnRightBottom.isEnabled = true
        if let image = image { btnRightBottom.setImage(image, for: .normal) }
        btnRightBottom.rx.tap
            .bind {
                tapEvent()
            }
            .disposed(by: disposeBag)
    }
    
    /* 버튼 이미지 변경 */
    func changeButtonImage(_ image: UIImage, position: ButtonPosition) {
        switch position {
        case .leftTop:
            self.btnLeftTop.setImage(image, for: .normal)
        case .leftBottom:
            self.btnLeftBottom.setImage(image, for: .normal)
        case .rightTop:
            self.btnRightTop.setImage(image, for: .normal)
        case .rightBottom:
            self.btnRightBottom.setImage(image, for: .normal)
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak private var btnLeftTop: UIButton!
    @IBOutlet weak private var btnRightTop: UIButton!
    @IBOutlet weak private var btnLeftBottom: UIButton!
    @IBOutlet weak private var btnRightBottom: UIButton!
    
    @IBOutlet weak var borderView: UIView!
}
