//
//  PaintViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/22.
//

import UIKit
import RxSwift
import RxGesture
import RxCocoa

class PaintViewController: UIViewController {
    static let storyboardID = "paintView"
    
    var stickers = [PaintStickerView]()
    let labelSticker = PaintStickerView()
    var bgColor = BehaviorRelay<Int>(value: 0xFFFFFF)
    var selectedControl: UIButton?
    var focusSticker: PaintStickerView? {
        didSet {
            oldValue?.isSelected = false
            focusSticker?.isSelected = true
            
            let currentComponentView = self.componentView.subviews.last
            if let colorOffImage = UIImage(named: "edge/Color-Off_24"),
               currentComponentView == self.colorChips?.view {
                oldValue?.changeButtonImage(colorOffImage, position: .rightTop)
                self.presentColorPicker(mode: .sticker)
            }
        }
    }
    
    enum ColorPickerMode {
        case background
        case sticker
    }
    
    var colorPickerMode: ColorPickerMode = .background
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        // 배경 색상 추가
        btnAddBgColor.rx.tap
            .bind {
                self.stackBackground.isHidden = true
                self.presentColorPicker(mode: .background)
                self.btnDone.isEnabled = false
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 변경 버튼
        btnEditBgColor.rx.tap
            .bind {
                self.presentColorPicker(mode: .background)
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 설정
        bgColor.asObservable()
            .observe(on: MainScheduler.instance)
            .bind { hexColor in
                self.paintView.backgroundColor = UIColor(rgb: hexColor)
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 선택 완료
        btnDone.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if let colorOffImage = UIImage(named: "edge/Color-Off_24") {
                    self.focusSticker?.changeButtonImage(colorOffImage, position: .rightTop)
                }
                self.presentStickerView()
            }
            .disposed(by: disposeBag)
        
        // 그림 스티커
        btnPicture.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                self.selectedControl = self.btnPicture
                if let stickerVC = self.pictureStickers {
                    self.selectButton(item: self.btnPicture)
                    self.present(asChildViewController: stickerVC)
                }
            }
            .disposed(by: disposeBag)
        
        // 라인 도형 스티커
        btnLineShape.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                self.selectedControl = self.btnLineShape
                if let stickerVC = self.shapeStickers {
                    self.selectButton(item: self.btnLineShape)
                    self.present(asChildViewController: stickerVC)
                    stickerVC.type.onNext(.lineShape)
                }
            }
            .disposed(by: disposeBag)
        
        // 도형 스티커
        btnFillShape.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                self.selectedControl = self.btnFillShape
                if let stickerVC = self.shapeStickers {
                    self.selectButton(item: self.btnFillShape)
                    self.present(asChildViewController: stickerVC)
                    stickerVC.type.onNext(.fillShape)
                }
            }
            .disposed(by: disposeBag)
        
        // 텍스트
        btnText.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                self.selectedControl = self.btnText
                if let textVC = self.textSticker {
                    self.selectButton(item: self.btnText)
                    self.present(asChildViewController: textVC)
                }
            }
            .disposed(by: disposeBag)
        
        // Paint View 배경 클릭 시
        paintView.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                self.focusSticker = nil
            }
            .disposed(by: disposeBag)
    }
    
    /* 색상 선택 화면 표시 */
    func presentColorPicker(mode: ColorPickerMode) {
        if let colorVC = self.colorChips {
            present(asChildViewController: colorVC)
            colorPickerMode = mode
            if mode == .background {
                colorVC.selectedColor.onNext(bgColor.value)
            } else if mode == .sticker {
                if let colorOnImage = UIImage(named: "edge/Color-On_24") {
                    self.focusSticker?.changeButtonImage(colorOnImage, position: .rightTop)
                }
                colorVC.selectedColor.onNext(focusSticker?.sticker.value.hexColor)
            }
            
            leftControls.isHidden = true
            rightControls.isHidden = false
            
            btnEditBgColor.isHidden = true
            btnUndo.isHidden = true
            btnRedo.isHidden = true
            btnDone.isHidden = false
        }
    }
    
    /* 스티커 추가 화면 표시 */
    func presentStickerView() {
        leftControls.isHidden = false
        rightControls.isHidden = false
        
        btnEditBgColor.isHidden = false
        btnUndo.isHidden = false
        btnRedo.isHidden = false
        btnDone.isHidden = true
        
        let selectedButton = selectedControl ?? btnPicture
        selectedButton?.sendActions(for: .touchUpInside)
    }
    
    /* leftControl 이미지 변경 */
    func selectButton(item: UIButton) {
        let pictureImage = item == btnPicture ? "Photo-On_24" : "Photo-Off_24"
        let lineShapeImage = item == btnLineShape ? "Line-Shape-On_24" : "Line-Shape-Off_24"
        let fillShapeImage = item == btnFillShape ? "Fill-Shape-On_24" : "Fill-Shape-Off_24"
        let textImage = item == btnText ? "Text-On_24" : "Text-Off_24"
        
        btnPicture.setImage(UIImage(named: pictureImage), for: .normal)
        btnLineShape.setImage(UIImage(named: lineShapeImage), for: .normal)
        btnFillShape.setImage(UIImage(named: fillShapeImage), for: .normal)
        btnText.setImage(UIImage(named: textImage), for: .normal)
    }
    
    private lazy var colorChips: ColorChipVC? = {
        guard let colorVC = self.storyboard?.instantiateViewController(withIdentifier: ColorChipVC.identifier) as? ColorChipVC else { return nil }
        colorVC.completeHandler = { (hexColor) in
            DispatchQueue.main.async {
                if self.colorPickerMode == .background {
                    self.bgColor.accept(hexColor)
                } else if self.colorPickerMode == .sticker,
                          var sticker = self.focusSticker?.sticker.value {
                    sticker.hexColor = hexColor
                    self.focusSticker?.sticker.accept(sticker)
                }
                
                self.btnDone.isEnabled = true
            }
        }
        
        return colorVC
    }()
    
    private lazy var pictureStickers: PictureStickerVC? = {
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: PictureStickerVC.identifier) as? PictureStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.addSticker(Sticker(image: image, contentMode: .scaleAspectFill)) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var shapeStickers: ShapeStickerVC? = {
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: ShapeStickerVC.identifier) as? ShapeStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.addSticker(Sticker(image: image, contentMode: .scaleAspectFit)) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var textSticker: TextStickerVC? = {
        guard let textVC = self.storyboard?.instantiateViewController(withIdentifier: TextStickerVC.identifier) as? TextStickerVC else { return nil }
        textVC.completeHandler = { (description) in
            DispatchQueue.main.async {
                self.addTextSticker(text: description)
            }
        }
        
        return textVC
    }()
    
    private func present(asChildViewController viewController: UIViewController) {
        if componentView.subviews.contains(viewController.view) {
            componentView.bringSubviewToFront(viewController.view)
            return
        }
        
        addChild(viewController)
        componentView.addSubview(viewController.view)
        
        viewController.view.frame = componentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var stackBackground: UIStackView!
    @IBOutlet weak var btnAddBgColor: UIButton!
    @IBOutlet weak var btnEditBgColor: UIButton!
    @IBOutlet weak var paintView: UIView!
    @IBOutlet weak var componentView: UIView!
    @IBOutlet weak var leftControls: UIStackView!
    @IBOutlet weak var rightControls: UIStackView!
    
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var btnPicture: UIButton!
    @IBOutlet weak var btnLineShape: UIButton!
    @IBOutlet weak var btnFillShape: UIButton!
    @IBOutlet weak var btnText: UIButton!
}

// MARK: - Sticker Functions

extension PaintViewController: UIGestureRecognizerDelegate {
    /* 스티커 추가 */
    private func addSticker(_ sticker: Sticker, centerPos: CGPoint? = nil) {
        let imageSticker = PaintStickerView()
        paintView.addSubview(imageSticker)
        
        let size = paintView.frame.width / 3
        imageSticker.frame.size = CGSize(width: size, height: size)
        imageSticker.center = centerPos ?? paintView.center
        imageSticker.sticker.accept(sticker)
        
        // 스티커 삭제
        imageSticker.setLeftTopButton {
            self.stickers = self.stickers.filter { $0 != self.focusSticker }
            self.focusSticker?.removeFromSuperview()
            self.focusSticker = nil
        }
        
        // 스티커 복제
        imageSticker.setLeftBottomButton {
            let centerPos = CGPoint(x: imageSticker.center.x + 26,
                                    y: imageSticker.center.y + 26)
            let cloneSticker = imageSticker.sticker.value
            self.addSticker(cloneSticker, centerPos: centerPos)
        }
        
        // 스티커 색상 변경
        imageSticker.setRightTopButton {
            self.presentColorPicker(mode: .sticker)
        }
        
        // 스티커 사이즈/각도 변경
        imageSticker.setRightBottomButton {
            
        }
        
        // Gesture
        imageSticker.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTapGesture(recognizer:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self,
                                                        action:#selector(self.handleRotateGesture(recognizer:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(self.handlePinchGesture(recognizer:)))
        rotateGesture.delegate = self
        pinchGesture.delegate = self
        imageSticker.gestureRecognizers = [panGesture, tapGesture, rotateGesture, pinchGesture]
        
        stickers.append(imageSticker)
        focusSticker = imageSticker
    }
    
    /* 설명 추가 */
    private func addTextSticker(text: String) {
        if let labelView = labelSticker.stickerView as? UILabel {
            labelView.sizeToFit()
            labelView.numberOfLines = text.components(separatedBy: "\n").count
            labelSticker.frame.size = CGSize(width: labelView.frame.width + 36,
                                             height: labelView.frame.height + 36)
        }
        labelSticker.sticker.accept(Sticker(text: text, hexColor: 0x000000))
        if text.isEmpty {
            labelSticker.stickerView?.frame.size = CGSize.zero
            focusSticker = nil
            return
        }
        labelSticker.center = paintView.center
        focusSticker = labelSticker
        
        if paintView.subviews.contains(labelSticker) { return }
        
        // 스티커 삭제
        labelSticker.setLeftTopButton {
            self.textSticker?.textView.text = ""
            self.focusSticker = nil
        }
        
        // 글자 색상 변경
        labelSticker.setRightTopButton {
            self.presentColorPicker(mode: .sticker)
        }
        
        // Gesture
        labelSticker.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTapGesture(recognizer:)))
        labelSticker.addGestureRecognizer(tapGesture)
        
        paintView.addSubview(labelSticker)
    }
    
    /* FocusSticker 변경 */
    func changeFocusSticker(_ view: UIView?) {
        guard let tappedSticker = view as? PaintStickerView else { return }
        focusSticker = tappedSticker
    }
    
    /* 드래그 */
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        changeFocusSticker(recognizer.view)
        recognizer.view?.center = recognizer.location(in: paintView)
    }
    
    /* 선택 시 Focus 변경 */
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        changeFocusSticker(recognizer.view)
    }
    
    /* 회전 */
    @objc func handleRotateGesture(recognizer: UIRotationGestureRecognizer) {
        changeFocusSticker(recognizer.view)
        if let rotationView = recognizer.view {
            rotationView.transform = rotationView.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0.0
        }
    }
    
    /* 크기 변경 */
    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        changeFocusSticker(recognizer.view)
        if let pinchView = recognizer.view {
            pinchView.transform = pinchView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1.0
        }
    }
    
    /* 동시에 여러 제스쳐 허용 */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
