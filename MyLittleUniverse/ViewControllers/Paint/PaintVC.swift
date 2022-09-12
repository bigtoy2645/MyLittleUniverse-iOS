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

class PaintVC: UIViewController {
    let vm = PaintViewModel()
    private let disposeBag = DisposeBag()
    
    var labelSticker = StickerView(sticker: Sticker(type: .text), view: UIView())
    var stickerCount = 0
    var stickerPos: [CGPoint] = []
    var isBgColorSelected = false
    var edgeView = StickerEdgeView()
    var edgeConstraint: [NSLayoutConstraint] = []
    var oldSticker: StickerView?
    let canUndo = BehaviorRelay<Bool>(value: false)
    let canRedo = BehaviorRelay<Bool>(value: false)
    let undoHandler = UndoManager()
    let redoHandler = UndoManager()
    private var lastScale: CGFloat = 1.0
    private var lastSize: CGSize = .zero
    private var lastPoint: CGPoint = .zero
    private var lastTransform: CGAffineTransform = .identity
    private var lastText: String = ""
    
    enum ColorPickerMode {
        case background
        case sticker
    }
    
    var colorPickerMode: ColorPickerMode = .background
    var textVC = TextStickerVC()
    var colorChipVC = ColorChipVC()
    var pictureVC = PictureStickerVC()
    var clippingVC = ClippingPictureStickerVC()
    var shapeVC = ShapeStickerVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paintView.clipsToBounds = true
        seperatorView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initStickerVC()
        
        paintView.addSubview(edgeView)
        edgeView.bounds.size = CGSize(width: view.frame.width / 3 + 32,
                                      height: view.frame.width / 3 + 32)
        edgeView.center = paintView.center
        configEdgeButton()
        
        setupBindings()
        btnEditBgColor.isHidden = true
        
        canUndo
            .bind(to: btnUndo.rx.isEnabled)
            .disposed(by: disposeBag)
        
        canUndo.map { $0 ? UIImage.undoOn : UIImage.undoOff }
            .bind(to: btnUndo.rx.image())
            .disposed(by: disposeBag)
        
        canRedo
            .bind(to: btnRedo.rx.isEnabled)
            .disposed(by: disposeBag)
        
        canRedo.map { $0 ? UIImage.redoOn : UIImage.redoOff }
            .bind(to: btnRedo.rx.image())
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let unitSize = paintView.frame.width / 6
        stickerPos = [
            CGPoint(x: unitSize * 3, y: unitSize * 3),  // 4
            CGPoint(x: unitSize, y: unitSize),          // 0
            CGPoint(x: unitSize * 3, y: unitSize),      // 1
            CGPoint(x: unitSize * 5, y: unitSize),      // 2
            CGPoint(x: unitSize, y: unitSize * 3),      // 3
            CGPoint(x: unitSize * 5, y: unitSize * 3),  // 5
            CGPoint(x: unitSize, y: unitSize * 5),      // 6
            CGPoint(x: unitSize * 3, y: unitSize * 5),  // 7
            CGPoint(x: unitSize * 5, y: unitSize * 5),  // 8
        ]
    }
    
    /* 화면 클릭 시 키보드 내림 */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    /* Binding */
    func setupBindings() {
        vm.focusSticker.map { $0 == nil }
            .bind {
                self.edgeView.isHidden = $0
                self.edgeView.isUserInteractionEnabled = !$0
            }
            .disposed(by: disposeBag)
        
        vm.focusSticker
            .bind { sticker in
                self.oldSticker?.view.translatesAutoresizingMaskIntoConstraints = true
                NSLayoutConstraint.deactivate(self.edgeConstraint)
                
                guard let sticker = sticker else { return }
                
                let stickerView = sticker.view
                self.edgeView.center = stickerView.center
                self.edgeView.transform = stickerView.transform
                self.edgeView.bounds.size = CGSize(width: stickerView.bounds.width + 32, height: stickerView.bounds.height + 32)
                stickerView.translatesAutoresizingMaskIntoConstraints = false
                self.edgeConstraint = [
                    stickerView.topAnchor.constraint(equalTo: self.edgeView.innerBorderView.topAnchor, constant: 3),
                    stickerView.bottomAnchor.constraint(equalTo: self.edgeView.innerBorderView.bottomAnchor, constant: -3),
                    stickerView.leftAnchor.constraint(equalTo: self.edgeView.innerBorderView.leftAnchor, constant: 3),
                    stickerView.rightAnchor.constraint(equalTo: self.edgeView.innerBorderView.rightAnchor, constant: -3),
                ]
                NSLayoutConstraint.activate(self.edgeConstraint)
                self.edgeView.layoutSubviews()
                self.edgeView.stickerView = stickerView
                if self.oldSticker?.sticker.value.type != sticker.sticker.value.type {
                    let image: UIImage? = sticker.sticker.value.type == .picture ? .editOff : .colorOff
                    self.edgeView.changeButtonImage(image, position: .rightTop)
                }
                self.oldSticker = sticker
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 추가
        btnAddBgColor.rx.tap
            .bind {
                self.stackBackground.isHidden = true
                self.presentColorPicker(mode: .background)
                self.btnDone.isEnabled = false
                self.seperatorView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 변경 버튼
        btnEditBgColor.rx.tap
            .bind {
                self.presentColorPicker(mode: .background)
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 설정
        vm.bgColor
            .bind(to: paintView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        vm.isEditing
            .bind(to: btnEditBgColor.rx.isHidden)
            .disposed(by: disposeBag)
        
        vm.isEditing
            .bind(to: btnUndo.rx.isHidden)
            .disposed(by: disposeBag)
        
        vm.isEditing
            .bind(to: btnRedo.rx.isHidden)
            .disposed(by: disposeBag)
        
        vm.isEditing.map { !$0 }
            .bind(to: btnDone.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 색상 선택 완료
        btnDone.rx.tap
            .bind {
                let buttonImage: UIImage? = self.vm.focusSticker.value?.sticker.value.type == .picture ? .editOff : .colorOff
                self.edgeView.changeButtonImage(buttonImage, position: .rightTop)
                self.edgeView.changeEditable(false)
                
                self.presentStickerView()
            }
            .disposed(by: disposeBag)
        
        // LeftControl Button
        vm.leftControl
            .observe(on: MainScheduler.instance)
            .bind {
                guard let button = $0 else { return }
                self.selectLeftControl(item: button)
                var childVC: UIViewController?
                
                switch button {
                case self.btnPicture:
                    childVC = self.pictureVC
                case self.btnLineShape:
                    childVC = self.shapeVC
                    self.shapeVC.type.onNext(.lineShape)
                case self.btnFillShape:
                    childVC = self.shapeVC
                    self.shapeVC.type.onNext(.fillShape)
                case self.btnText:
                    childVC = self.textVC
                default: break
                }
                
                if let childVC = childVC {
                    self.present(asChildViewController: childVC, view: self.componentView)
                }
            }
            .disposed(by: disposeBag)
        
        // 그림 스티커
        btnPicture.rx.tap
            .bind { self.vm.leftControl.accept(self.btnPicture) }
            .disposed(by: disposeBag)
        
        // 라인 도형 스티커
        btnLineShape.rx.tap
            .bind { self.vm.leftControl.accept(self.btnLineShape) }
            .disposed(by: disposeBag)
        
        // 도형 스티커
        btnFillShape.rx.tap
            .bind { self.vm.leftControl.accept(self.btnFillShape) }
            .disposed(by: disposeBag)
        
        // 텍스트
        btnText.rx.tap
            .bind { self.vm.leftControl.accept(self.btnText) }
            .disposed(by: disposeBag)
        
        // Paint View 배경 클릭 시
        paintView.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                self.vm.focusSticker.accept(nil)
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        // 작업 취소
        btnUndo.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if self.undoHandler.canUndo {
                    self.undoHandler.undo()
                    self.canRedo.accept(true)
                    self.canUndo.accept(self.undoHandler.canUndo)
                }
            }
            .disposed(by: disposeBag)
        
        // 작업 재개
        btnRedo.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if self.redoHandler.canUndo {
                    self.redoHandler.undo()
                    self.canRedo.accept(self.redoHandler.canUndo)
                }
            }
            .disposed(by: disposeBag)
        
        // TextView Focus
        textVC.isFocused
            .subscribe(onNext: { isFocused in
                if isFocused {
                    self.lastText = self.labelSticker.sticker.value.text ?? ""
                } else {
                    self.changeTextSticker(self.labelSticker.sticker.value.text ?? "")
                }
            })
            .disposed(by: disposeBag)
    }
    
    /* 스티커 추가 화면 초기화 */
    func initStickerVC() {
        if let textVC = Route.getVC(.textStickerVC) as? TextStickerVC {
            textVC.emotion.accept(vm.emotion.value)
            textVC.completeHandler = { (description) in
                DispatchQueue.main.async {
                    self.addTextSticker(text: description)
                }
            }
            self.textVC = textVC
        }
        
        if let colorChipVC = Route.getVC(.colorChipVC) as? ColorChipVC {
            colorChipVC.completeHandler = { (hexColor) in
                DispatchQueue.main.async {
                    if self.colorPickerMode == .background {
                        self.pickBgColor(hexColor)
                    }
                    else if self.colorPickerMode == .sticker, let focusSticker = self.vm.focusSticker.value {
                        self.pickSticker(focusSticker, hexColor: hexColor)
                    }
                    self.btnDone.isEnabled = true
                }
            }
            self.colorChipVC = colorChipVC
        }
        
        if let pictureVC = Route.getVC(.pictureStickerVC) as? PictureStickerVC {
            pictureVC.completeHandler = { (image) in
                DispatchQueue.main.async {
                    if let image = image { self.createSticker(Sticker(type: .picture, image: image)) }
                }
            }
            self.pictureVC = pictureVC
        }
        
        if let clippingVC = Route.getVC(.clippingStickerVC) as? ClippingPictureStickerVC {
            clippingVC.completeHandler = { (image) in
                if let focusSticker = self.vm.focusSticker.value,
                   let image = image {
                    self.pickSticker(focusSticker, clippingImage: image)
                }
            }
            self.clippingVC = clippingVC
        }
        
        if let shapeVC = Route.getVC(.shapeStickerVC) as? ShapeStickerVC {
            shapeVC.completeHandler = { (image) in
                DispatchQueue.main.async {
                    if let image = image { self.createSticker(Sticker(type: .shape, image: image)) }
                }
            }
            
            self.shapeVC = shapeVC
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    /* 색상 선택 화면 표시 */
    func presentColorPicker(mode: ColorPickerMode) {
        present(asChildViewController: colorChipVC, view: componentView)
        colorPickerMode = mode
        if mode == .background {        // 기존 배경 색상 지정
            colorChipVC.selectedColor.onNext(vm.bgHexColor.value)
        } else if mode == .sticker {    // 기존 스티커 색상 지정
            self.edgeView.changeButtonImage(.colorOn, position: .rightTop)
            self.edgeView.changeEditable(true)
            colorChipVC.selectedColor.onNext(vm.focusSticker.value?.sticker.value.hexColor)
        }
        
        leftControls.isHidden = true
        rightControls.isHidden = false
        vm.isEditing.accept(true)
    }
    
    /* 색상 선택 화면 표시 */
    func presentClippingMask(image: UIImage?) {
        clippingVC.originImage.onNext(image)
        present(asChildViewController: clippingVC, view: componentView)
        
        edgeView.changeButtonImage(.editOn, position: .rightTop)
        edgeView.changeEditable(true)
        
        leftControls.isHidden = true
        rightControls.isHidden = false
        vm.isEditing.accept(true)
    }
    
    /* 스티커 추가 화면 표시 */
    func presentStickerView() {
        leftControls.isHidden = false
        rightControls.isHidden = false
        vm.isEditing.accept(false)
        
        let selectedButton = vm.leftControl.value ?? btnText
        selectedButton?.sendActions(for: .touchUpInside)
    }
    
    /* leftControl 이미지 변경 */
    func selectLeftControl(item: UIButton) {
        let pictureImage: UIImage? = item == btnPicture ? .photoOn : .photoOff
        let lineShapeImage: UIImage? = item == btnLineShape ? .lineShapeOn : .lineShapeOff
        let fillShapeImage: UIImage? = item == btnFillShape ? .fillShapeOn : .fillShapeOff
        let textImage: UIImage? = item == btnText ? .textOn : .textOff
        
        btnPicture.setImage(pictureImage, for: .normal)
        btnLineShape.setImage(lineShapeImage, for: .normal)
        btnFillShape.setImage(fillShapeImage, for: .normal)
        btnText.setImage(textImage, for: .normal)
    }
    
    /* 배경 색상 선택 */
    private func pickBgColor(_ hexColor: Int) {
        if isBgColorSelected {
            let oldHexColor = self.vm.bgHexColor.value
            undoHandler.registerUndo(withTarget: self) {
                $0.vm.bgHexColor.accept(oldHexColor)
                $0.redoHandler.registerUndo(withTarget: self) { $0.pickBgColor(hexColor) }
            }
            canUndo.accept(true)
        } else {
            isBgColorSelected = true
        }
        self.vm.bgHexColor.accept(hexColor)
    }
    
    /* 스티커 색상 선택 */
    private func pickSticker(_ stickerView: StickerView, hexColor: Int) {
        let oldHexColor = stickerView.sticker.value.hexColor
        
        undoHandler.registerUndo(withTarget: self) {
            $0.updateSticker(stickerView, hexColor: oldHexColor)
            $0.redoHandler.registerUndo(withTarget: self) {
                $0.pickSticker(stickerView, hexColor: hexColor)
            }
        }
        canUndo.accept(true)
        
        var sticker = stickerView.sticker.value
        sticker.hexColor = hexColor
        stickerView.sticker.accept(sticker)
        vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 모양 선택 */
    func pickSticker(_ stickerView: StickerView, clippingImage: UIImage) {
        guard let imageSticker = stickerView.view as? UIImageView else { return }
        
        let oldImage = stickerView.sticker.value.image
        undoHandler.registerUndo(withTarget: self) {
            $0.updateSticker(stickerView, image: oldImage)
            $0.redoHandler.registerUndo(withTarget: self) {
                $0.pickSticker(stickerView, clippingImage: clippingImage)
            }
        }
        canUndo.accept(true)
        
        imageSticker.image = clippingImage
        var sticker = stickerView.sticker.value
        sticker.image = clippingImage
        stickerView.sticker.accept(sticker)
        vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 위치 변경 */
    func changeStickerPosition(_ stickerView: StickerView, center: CGPoint, lastCenter: CGPoint) {
        updateSticker(stickerView, center: center)
        undoHandler.registerUndo(withTarget: self) {
            $0.updateSticker(stickerView, center: lastCenter)
            $0.redoHandler.registerUndo(withTarget: self) {
                $0.changeStickerPosition(stickerView, center: center, lastCenter: lastCenter)
            }
        }
        canUndo.accept(true)
    }
    
    /* 스티커 회전 변경 */
    func changeStickerTransform(_ stickerView: StickerView, transform: CGAffineTransform, lastTransform: CGAffineTransform) {
        updateSticker(stickerView, transform: transform)
        undoHandler.registerUndo(withTarget: self) {
            $0.updateSticker(stickerView, transform: lastTransform)
            $0.redoHandler.registerUndo(withTarget: self) {
                $0.changeStickerTransform(stickerView, transform: transform, lastTransform: lastTransform)
            }
        }
        canUndo.accept(true)
    }
    
    /* 스티커 크기 변경 */
    func changeStickerSize(_ stickerView: StickerView, size: CGSize, lastSize: CGSize) {
        updateSticker(stickerView, size: size)
        undoHandler.registerUndo(withTarget: self) {
            $0.updateSticker(stickerView, size: lastSize)
            $0.redoHandler.registerUndo(withTarget: self) {
                $0.changeStickerSize(stickerView, size: size, lastSize: lastSize)
            }
        }
        canUndo.accept(true)
    }
    
    /* 텍스트 스티커 내용 변경 */
    func changeTextSticker(_ text: String) {
        addTextSticker(text: text)
        undoHandler.registerUndo(withTarget: self) {
            $0.addTextSticker(text: self.lastText)
            $0.redoHandler.registerUndo(withTarget: self) {
                $0.changeTextSticker(text)
            }
        }
        canUndo.accept(true)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var stackBackground: UIStackView!
    @IBOutlet weak var btnAddBgColor: UIButton!
    @IBOutlet weak var btnEditBgColor: UIButton!
    
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var controlView: UIView!
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

extension PaintVC: UIGestureRecognizerDelegate {
    func configEdgeButton() {
        // 스티커 삭제
        edgeView.setLeftTopButton {
            if let focusSticker = self.vm.focusSticker.value {
                if focusSticker.sticker.value.type == .text {
                    self.textVC.textView.text = ""
                    self.textVC.textView.endEditing(true)
                }
                self.removeSticker(focusSticker)
            }
        }
        
        // 스티커 복제
        edgeView.setLeftBottomButton {
            guard let focusSticker = self.vm.focusSticker.value else { return }
            
            let centerPos = CGPoint(x: focusSticker.view.center.x + 26,
                                    y: focusSticker.view.center.y + 26)
            
            self.createSticker(focusSticker.sticker.value, size: focusSticker.view.bounds.size, centerPos: centerPos, transform: focusSticker.view.transform)
        }
        
        // 스티커 색상/모양 변경
        edgeView.setRightTopButton {
            guard let focusSticker = self.vm.focusSticker.value else { return }
            let stickerType = focusSticker.sticker.value.type
            if stickerType == .shape || stickerType == .text {
                self.presentColorPicker(mode: .sticker)
            }
            else if stickerType == .picture {
                let image = focusSticker.sticker.value.image
                self.presentClippingMask(image: image)
            }
        }
        
        // 스티커 사이즈/각도 변경
        edgeView.setRightBottomButton { }
        edgeView.transHanlder = { beforeTrans, afterTrans, beforeSize, afterSize in
            guard let stickerView = self.vm.focusSticker.value else { return }
            
            self.changeStickerTransform(stickerView, transform: afterTrans, lastTransform: beforeTrans)
            self.changeStickerSize(stickerView, size: afterSize, lastSize: beforeSize)
        }
        
        // Gesture
        edgeView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self,
                                                        action:#selector(self.handleRotateGesture(recognizer:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(self.handlePinchGesture(recognizer:)))
        rotateGesture.delegate = self
        pinchGesture.delegate = self
        edgeView.gestureRecognizers = [panGesture, rotateGesture, pinchGesture]
    }
    
    /* 스티커 복원 */
    private func restoreSticker(_ stickerView: StickerView, isUndo: Bool = false) {
        paintView.insertSubview(stickerView.view, belowSubview: edgeView)
        stickerCount += 1
        
        if !isUndo {
            undoHandler.registerUndo(withTarget: self) {
                $0.removeSticker(stickerView, isUndo: true)
                $0.redoHandler.registerUndo(withTarget: self) {
                    $0.restoreSticker(stickerView)
                }
            }
            canUndo.accept(true)
        }
        
        vm.addSticker(stickerView)
        vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 생성 */
    private func createSticker(_ sticker: Sticker,
                               size: CGSize? = nil,
                               centerPos: CGPoint? = nil,
                               transform: CGAffineTransform? = nil,
                               isUndo: Bool = false) {
        let imageSticker = UIImageView()
        paintView.insertSubview(imageSticker, belowSubview: edgeView)
        imageSticker.clipsToBounds = true
        imageSticker.tintColor = UIColor(rgb: sticker.hexColor)
        imageSticker.image = sticker.image
        imageSticker.contentMode = .scaleAspectFit
        imageSticker.translatesAutoresizingMaskIntoConstraints = true
        
        if let transform = transform, let centerPos = centerPos, let size = size {
            imageSticker.bounds.size = size
            imageSticker.center = centerPos
            imageSticker.transform = transform
        } else {
            let size = paintView.frame.width / 3
            imageSticker.bounds.size = CGSize(width: size, height: size)
            imageSticker.center = stickerPos[stickerCount % stickerPos.count]
            imageSticker.transform = imageSticker.transform
        }
        
        stickerCount += 1
        
        imageSticker.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTapGesture(recognizer:)))
        imageSticker.gestureRecognizers = [tapGesture]
        
        let stickerView = StickerView(sticker: sticker, view: imageSticker)
        
        // Undo/Redo
        if !isUndo {
            undoHandler.registerUndo(withTarget: self) {
                $0.removeSticker(stickerView, isUndo: true)
                $0.redoHandler.registerUndo(withTarget: self) {
                    $0.restoreSticker(stickerView)
                }
            }
            canUndo.accept(true)
        }
        
        vm.addSticker(stickerView)
        vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 추가 */
    func addSticker(_ stickerView: StickerView) {
        paintView.insertSubview(stickerView.view, belowSubview: edgeView)
        vm.addSticker(stickerView)
        edgeView.stickerView.frame = stickerView.view.frame
        vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 삭제 */
    func removeSticker(_ stickerView: StickerView, isUndo: Bool = false) {
        vm.removeSticker(stickerView)
        if stickerView == vm.focusSticker.value {
            vm.focusSticker.value?.view.removeFromSuperview()
            vm.focusSticker.accept(nil)
        } else {
            stickerView.view.removeFromSuperview()
        }
        
        if !isUndo {
            undoHandler.registerUndo(withTarget: self) {
                $0.restoreSticker(stickerView, isUndo: true)
                $0.redoHandler.registerUndo(withTarget: self) { $0.removeSticker(stickerView) }
            }
            canUndo.accept(true)
        }
    }
    
    /* 설명 추가 */
    private func addTextSticker(text: String) {
        var labelView = UILabel()
        if let oldLabelView = labelSticker.view as? UILabel,
           paintView.subviews.contains(labelSticker.view) {
            labelView = oldLabelView
            vm.removeSticker(labelSticker)
        } else {
            edgeView.transform = .identity
            labelView.numberOfLines = 0
            labelView.textColor = .black
            labelView.textAlignment = .center
            labelView.lineBreakMode = .byClipping
            labelView.isUserInteractionEnabled = true
            labelView.adjustsFontSizeToFitWidth = true
            labelView.minimumScaleFactor = 0.1
            labelView.center = stickerPos[0]
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(self.handleTapGesture(recognizer:)))
            labelView.gestureRecognizers = [tapGesture]
            paintView.insertSubview(labelView, belowSubview: edgeView)
        }
        
        labelSticker.view = labelView
        if let textArea = textVC.textView {
            labelView.text = text
            textArea.text = text
            let size = labelView.sizeThatFits(textArea.visibleSize)
            labelView.bounds.size = CGSize(width: size.width + 10, height: size.height + 10)
        }
        
        let labelColor = labelView.textColor.rgb() ?? labelSticker.sticker.value.hexColor
        labelSticker.sticker.accept(Sticker(type: .text, text: text, hexColor: labelColor))
        if text.isEmpty {
            labelSticker.view.bounds.size = CGSize.zero
            vm.focusSticker.accept(nil)
            return
        }
        vm.focusSticker.accept(labelSticker)
        vm.addSticker(labelSticker)
    }
    
    /* 드래그 */
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        guard let focusView = recognizer.view else { return }
        let translation = recognizer.translation(in: view)
        let nextCenter = CGPoint(x: lastPoint.x + translation.x,
                                 y: lastPoint.y + translation.y)
        
        switch recognizer.state {
        case .began:
            lastPoint = focusView.center
        case .changed:
            focusView.center = nextCenter
        case .ended:
            if let focusSticker = self.vm.focusSticker.value {
                self.changeStickerPosition(focusSticker, center: nextCenter, lastCenter: lastPoint)
            }
        default: break
        }
    }
    
    /* 선택 시 Focus 변경 */
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        for sticker in vm.stickers.value {
            if sticker.view == recognizer.view {
                if sticker.sticker.value.type == .text {
                    vm.leftControl.accept(self.btnText)
                }
                vm.focusSticker.accept(sticker)
                break
            }
        }
    }
    
    /* 회전 */
    @objc func handleRotateGesture(recognizer: UIRotationGestureRecognizer) {
        guard let rotationView = recognizer.view else { return }
        
        switch recognizer.state {
        case .began:
            lastTransform = rotationView.transform
        case .changed:
            rotationView.transform = rotationView.transform.rotated(by: recognizer.rotation)
        case .ended:
            if let focusSticker = self.vm.focusSticker.value {
                changeStickerTransform(focusSticker, transform: rotationView.transform.rotated(by: recognizer.rotation), lastTransform: lastTransform)
            }
        default: break
        }
        
        if let focusSticker = vm.focusSticker.value?.view {
            focusSticker.transform = focusSticker.transform.rotated(by: recognizer.rotation)
            edgeView.updateHorizontal(state: recognizer.state, transform: focusSticker.transform)
        }
        recognizer.rotation = 0.0
    }
    
    /* 크기 변경 */
    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        guard let pinchView = recognizer.view,
              let focusSticker = vm.focusSticker.value else { return }
        
        if recognizer.state == .began {
            lastScale = recognizer.scale
            lastSize = focusSticker.view.bounds.size
        }
        
        var newScale = 1.0 - (lastScale - recognizer.scale)
        let currentScale = (pinchView.layer.value(forKeyPath: "transform.scale") as? NSNumber)?.floatValue ?? 1.0
        let minScale: CGFloat = 0.5
        
        if recognizer.state == .began || recognizer.state == .changed {
            newScale = max(newScale, minScale / (CGFloat)(currentScale))
            updateSticker(focusSticker, scale: newScale)
            recognizer.scale = 1.0
            lastScale = recognizer.scale
        } else if recognizer.state == .ended {
            let newSize = CGSize(width: focusSticker.view.bounds.size.width * newScale,
                                 height: focusSticker.view.bounds.size.height * newScale)
            changeStickerSize(focusSticker, size: newSize, lastSize: lastSize)
        }
    }
    
    /* 동시에 여러 제스쳐 허용 */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /* 스티커 색상 변경 */
    private func updateSticker(_ stickerView: StickerView, hexColor: Int) {
        if let stickerIndex = vm.stickers.value.firstIndex(of: stickerView) {
            var sticker = stickerView.sticker.value
            sticker.hexColor = hexColor
            stickerView.sticker.accept(sticker)
            var stickers = vm.stickers.value
            stickers[stickerIndex] = stickerView
            vm.stickers.accept(stickers)
        }
    }
    
    /* 스티커 이미지 변경 */
    private func updateSticker(_ stickerView: StickerView, image: UIImage?) {
        if let stickerIndex = vm.stickers.value.firstIndex(of: stickerView) {
            var sticker = stickerView.sticker.value
            sticker.image = image
            stickerView.sticker.accept(sticker)
            var stickers = vm.stickers.value
            stickers[stickerIndex] = stickerView
            vm.stickers.accept(stickers)
        }
    }
    
    /* 스티커 위치 변경 */
    private func updateSticker(_ stickerView: StickerView, center: CGPoint) {
        stickerView.view.center = center
        self.vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 회전 변경 */
    private func updateSticker(_ stickerView: StickerView, transform: CGAffineTransform) {
        stickerView.view.transform = transform
        self.vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 크기 변경 */
    private func updateSticker(_ stickerView: StickerView, scale: CGFloat) {
        stickerView.view.bounds.size = CGSize(width: stickerView.view.bounds.width * scale,
                                              height: stickerView.view.bounds.height * scale)
        if let labelSticker = stickerView.view as? UILabel {
            let font = labelSticker.font.pointSize
            labelSticker.font = .systemFont(ofSize: font * scale)
        }
        self.vm.focusSticker.accept(stickerView)
    }
    
    /* 스티커 크기 변경 */
    private func updateSticker(_ stickerView: StickerView, size: CGSize) {
        let oldSize = stickerView.view.bounds.size
        let scale = 1 + (size.width - oldSize.width) / oldSize.width
        updateSticker(stickerView, scale: scale)
    }
}
