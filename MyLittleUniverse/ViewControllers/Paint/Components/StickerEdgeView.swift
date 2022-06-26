//
//  StickerEdgeView.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/27.
//

import UIKit
import RxSwift
import RxCocoa

class StickerEdgeView: UIView {
    var stickerView = UIView()
    private let disposeBag = DisposeBag()
    
    enum ButtonPosition {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
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
        guard let view = Bundle.main.loadNibNamed("StickerEdgeView",
                                                  owner: self,
                                                  options: nil)?.first as? UIView else { return }
        view.frame = self.bounds
        addSubview(view)
        
        borderView.layer.borderColor = UIColor.white.cgColor
        outborderView.layer.borderColor = UIColor.gray300.cgColor
        innerBorderView.layer.borderColor = UIColor.gray300.cgColor
        
        borderView.layer.borderWidth = 1
        outborderView.layer.borderWidth = 0.2
        innerBorderView.layer.borderWidth = 0.2
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        btnRightBottom.gestureRecognizers = [panGesture]
    }
    
    /* 드래그 */
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self)
        let scaleX = location.x / btnRightBottom.frame.origin.x
        let scaleY = location.y / btnRightBottom.frame.origin.y
        var scale = max(scaleX, scaleY)
        
        let angleRightBottom = atan(btnRightBottom.frame.origin.y / btnRightBottom.frame.origin.x)
        let angleLocation = atan(location.y / location.x)
        let angle = angleLocation - angleRightBottom

        if recognizer.state == .began || recognizer.state == .changed {
            let currentScale = (layer.value(forKeyPath: "transform.scale") as? NSNumber)?.floatValue
            let minScale: CGFloat = 0.5
            
            if let currentScale = currentScale {
                scale = max(scale, minScale / (CGFloat)(currentScale))
                bounds.size = CGSize(width: bounds.width * scale, height: bounds.height * scale)
                transform = transform.rotated(by: angle)
                stickerView.bounds.size = CGSize(width: stickerView.bounds.width * scale, height: stickerView.bounds.height * scale)
                stickerView.transform = stickerView.transform.rotated(by: angle)
            }
        }
        updateHorizontal(state: recognizer.state, transform: stickerView.transform)
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
    func changeButtonImage(_ image: UIImage?, position: ButtonPosition) {
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
    
    /* 편집 상태 변경 */
    func changeEditable(_ isEditable: Bool) {
        if isEditable {
            changeButtonImage(.deleteDisabled, position: .leftTop)
            changeButtonImage(.rotateDisabled, position: .leftBottom)
            changeButtonImage(.sizeDisabled, position: .rightBottom)
        } else {
            changeButtonImage(.deleteOff, position: .leftTop)
            changeButtonImage(.rotateOff, position: .leftBottom)
            changeButtonImage(.sizeOff, position: .rightBottom)
        }
        
        btnLeftTop.isUserInteractionEnabled = !isEditable
        btnLeftBottom.isUserInteractionEnabled = !isEditable
        btnRightBottom.isUserInteractionEnabled = !isEditable
    }
    
    /* 수직/수평 */
    func updateHorizontal(state: UIGestureRecognizer.State, transform: CGAffineTransform) {
        if state == .began || state == .changed {
            let radians = atan2f(Float(transform.b), Float(transform.a))
            let degrees = Int(round(abs(radians * (180 / .pi))))
            if degrees % 90 == 0 {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                borderView.layer.borderColor = UIColor.pointPurple.cgColor
                innerBorderView.layer.borderColor = UIColor.pointPurple.cgColor
                outborderView.layer.borderColor = UIColor.pointPurple.cgColor
            } else {
                borderView.layer.borderColor = UIColor.white.cgColor
                innerBorderView.layer.borderColor = UIColor.gray300.cgColor
                outborderView.layer.borderColor = UIColor.gray300.cgColor
            }
        } else {
            borderView.layer.borderColor = UIColor.white.cgColor
            innerBorderView.layer.borderColor = UIColor.gray300.cgColor
            outborderView.layer.borderColor = UIColor.gray300.cgColor
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak private var btnLeftTop: UIButton!
    @IBOutlet weak private var btnRightTop: UIButton!
    @IBOutlet weak private var btnLeftBottom: UIButton!
    @IBOutlet weak private var btnRightBottom: UIButton!
    
    @IBOutlet weak var innerBorderView: UIView!
    @IBOutlet weak var outborderView: UIView!
    @IBOutlet weak var borderView: UIView!
}
