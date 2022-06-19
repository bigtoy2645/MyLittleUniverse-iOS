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
    
    private var lastScale: CGFloat = 1.0
    private var lastPoint: CGPoint = .zero
    let labelSticker = StickerEdgeView()
    var stickerCount = 0
    var stickerPos: [CGPoint] = []
    var isBgColorSelected = false
    var focusSticker: StickerEdgeView? {
        didSet {
            oldValue?.isSelected = false
            focusSticker?.isSelected = true
            if self.componentView.subviews.last == self.colorChips?.view {
                oldValue?.changeButtonImage(.colorOff, position: .rightTop)
                oldValue?.changeEditable(false)
                self.presentColorPicker(mode: .sticker)
            }
        }
    }
    
    private var undoFunctions: [Handler] = [] {
        didSet {
            DispatchQueue.main.async {
                let isUndoEnable = self.undoFunctions.count > 0
                self.btnUndo.isEnabled = isUndoEnable
                if let undoImage: UIImage = isUndoEnable ? .undoOn : .undoOff {
                    self.btnUndo.setImage(undoImage, for: .normal)
                }
            }
        }
    }
    private var redoFunctions: [(() -> Void)] = [] {
        didSet {
            DispatchQueue.main.async {
                let isRedoEnable = self.redoFunctions.count > 0
                self.btnRedo.isEnabled = isRedoEnable
                if let redoImage: UIImage = isRedoEnable ? .redoOn : .redoOff {
                    self.btnRedo.setImage(redoImage, for: .normal)
                }
            }
        }
    }
    
    enum ColorPickerMode {
        case background
        case sticker
    }
    
    var colorPickerMode: ColorPickerMode = .background
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paintView.clipsToBounds = true
        configureTextSticker()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupBindings()
        btnEditBgColor.isHidden = true
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
                let buttonImage: UIImage? = self.focusSticker?.sticker.value.type == .picture ? .editOff : .colorOff
                self.focusSticker?.changeButtonImage(buttonImage, position: .rightTop)
                self.focusSticker?.changeEditable(false)
                
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
                    childVC = self.pictureStickers
                case self.btnLineShape:
                    childVC = self.shapeStickers
                    self.shapeStickers?.type.onNext(.lineShape)
                case self.btnFillShape:
                    childVC = self.shapeStickers
                    self.shapeStickers?.type.onNext(.fillShape)
                case self.btnText:
                    childVC = self.textSticker
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
                self.focusSticker = nil
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        // 작업 취소
        btnUndo.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if let handler = self.undoFunctions.popLast() {
                    handler.undo()
                    self.redoFunctions.append(handler.redo)
                }
            }
            .disposed(by: disposeBag)
        
        // 작업 재개
        btnRedo.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if let redo = self.redoFunctions.popLast() { redo() }
            }
            .disposed(by: disposeBag)
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
        if let colorVC = self.colorChips {
            present(asChildViewController: colorVC, view: componentView)
            colorPickerMode = mode
            if mode == .background {        // 기존 배경 색상 지정
                colorVC.selectedColor.onNext(vm.bgHexColor.value)
            } else if mode == .sticker {    // 기존 스티커 색상 지정
                self.focusSticker?.changeButtonImage(.colorOn, position: .rightTop)
                self.focusSticker?.changeEditable(true)
                colorVC.selectedColor.onNext(focusSticker?.sticker.value.hexColor)
            }
            
            leftControls.isHidden = true
            rightControls.isHidden = false
            vm.isEditing.accept(true)
        }
    }
    
    /* 색상 선택 화면 표시 */
    func presentClippingMask(image: UIImage?) {
        guard let clippingVC = clippingStickers else { return }
        
        clippingVC.originImage.onNext(image)
        present(asChildViewController: clippingVC, view: componentView)
        
        focusSticker?.changeButtonImage(.editOn, position: .rightTop)
        focusSticker?.changeEditable(true)
        
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
    
    /* 스티커 색상 변경 */
    private func updateStickerColor(stickerView: StickerEdgeView, hexColor: Int) {
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
    private func updateStickerImage(stickerView: StickerEdgeView, image: UIImage?) {
        if let stickerIndex = vm.stickers.value.firstIndex(of: stickerView) {
            var sticker = stickerView.sticker.value
            sticker.image = image
            stickerView.sticker.accept(sticker)
            var stickers = vm.stickers.value
            stickers[stickerIndex] = stickerView
            vm.stickers.accept(stickers)
        }
    }
    
    /* 색상 선택 */
    private func pickColor(_ hexColor: Int, isUndoAction: Bool = false) {
        if self.colorPickerMode == .background {    // 배경 색상 변경
            if isBgColorSelected {
                let oldHexColor = self.vm.bgHexColor.value
                undoFunctions.append(Handler(undo: { self.vm.bgHexColor.accept(oldHexColor) },
                                             redo: { self.vm.bgHexColor.accept(hexColor) }))
            } else {
                isBgColorSelected = true
            }
            self.vm.bgHexColor.accept(hexColor)
        } else if self.colorPickerMode == .sticker, // 스티커 색상 변경
                  let stickerView = self.focusSticker {
            var sticker = stickerView.sticker.value
            let oldHexColor = sticker.hexColor
            
            let handler = Handler {
                self.updateStickerColor(stickerView: stickerView, hexColor: oldHexColor)
            } redo: {
                self.updateStickerColor(stickerView: stickerView, hexColor: hexColor)
            }
            undoFunctions.append(handler)
            
            sticker.hexColor = hexColor
            self.focusSticker?.sticker.accept(sticker)
        }
    }
    
    private lazy var colorChips: ColorChipVC? = {
        guard let colorVC = Route.getVC(.colorChipVC) as? ColorChipVC else { return nil }
        colorVC.completeHandler = { (hexColor) in
            DispatchQueue.main.async {
                self.pickColor(hexColor)
                self.btnDone.isEnabled = true
            }
        }
        return colorVC
    }()
    
    private lazy var pictureStickers: PictureStickerVC? = {
        guard let stickerVC = Route.getVC(.pictureStickerVC) as? PictureStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.createSticker(Sticker(type: .picture, image: image)) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var clippingStickers: ClippingPictureStickerVC? = {
        guard let stickerVC = Route.getVC(.clippingStickerVC) as? ClippingPictureStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image,
                   let stickerView = self.focusSticker {
                    var sticker = stickerView.sticker.value
                    let oldImage = sticker.image
                    self.undoFunctions.append(Handler(undo: { self.updateStickerImage(stickerView: stickerView, image: oldImage) },
                                                      redo: { self.updateStickerImage(stickerView: stickerView, image: image) }))
                    
                    sticker.image = image
                    self.focusSticker?.sticker.accept(sticker)
                }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var shapeStickers: ShapeStickerVC? = {
        guard let stickerVC = Route.getVC(.shapeStickerVC) as? ShapeStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.createSticker(Sticker(type: .shape, image: image)) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var textSticker: TextStickerVC? = {
        guard let textVC = Route.getVC(.textStickerVC) as? TextStickerVC else { return nil }
        textVC.emotion.accept(vm.emotion.value)
        textVC.completeHandler = { (description) in
            DispatchQueue.main.async {
                self.addTextSticker(text: description)
            }
        }
        
        return textVC
    }()
    
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

extension PaintVC: UIGestureRecognizerDelegate {
    /* 스티커 생성 */
    private func createSticker(_ sticker: Sticker,
                               centerPos: CGPoint? = nil,
                               transform: CGAffineTransform? = nil,
                               isUndoAction: Bool = false) {
        let imageSticker = StickerEdgeView()
        paintView.addSubview(imageSticker)
        
        // TODO - 32 -> 상대값
        let size = paintView.frame.width / 3 + 32
        imageSticker.frame.size = CGSize(width: size, height: size)
        imageSticker.center = centerPos ?? stickerPos[stickerCount % stickerPos.count]
        imageSticker.transform = transform ?? imageSticker.transform
        imageSticker.contentMode = .scaleAspectFit
        imageSticker.sticker.accept(sticker)
        stickerCount += 1
        
        // 스티커 삭제
        imageSticker.setLeftTopButton {
            self.removeSticker(imageSticker)
        }
        
        // 스티커 90도 회전
        imageSticker.setLeftBottomButton {
            guard let stickerView = imageSticker.stickerView else { return }
            stickerView.transform = stickerView.transform.rotated(by: .pi / 2)
        }
        
        // 스티커 색상 변경
        if sticker.type == .shape {
            imageSticker.setRightTopButton {
                self.presentColorPicker(mode: .sticker)
            }
        } else if sticker.type == .picture {
            imageSticker.setRightTopButton(image: .editOff) {
                self.presentClippingMask(image: sticker.image)
            }
        }
        
        // 스티커 사이즈/각도 변경
        imageSticker.setRightBottomButton { }
        
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
        
        // Undo/Redo
        if !isUndoAction {
            undoFunctions.append(Handler(undo: { self.removeSticker(imageSticker, isUndoAction: true) },
                                         redo: { self.addSticker(imageSticker) }))
        }
        
        vm.addSticker(imageSticker)
        focusSticker = imageSticker
    }
    
    /* 스티커 추가 */
    func addSticker(_ sticker: StickerEdgeView) {
        paintView.addSubview(sticker)
        vm.addSticker(sticker)
        focusSticker = sticker
    }
    
    /* 스티커 삭제 */
    func removeSticker(_ sticker: StickerEdgeView, isUndoAction: Bool = false) {
        vm.removeSticker(sticker)
        if sticker == focusSticker {
            focusSticker?.removeFromSuperview()
            focusSticker = nil
        } else {
            sticker.removeFromSuperview()
        }
        
        if !isUndoAction {
            undoFunctions.append(Handler(undo: { self.addSticker(sticker) },
                                         redo: { self.removeSticker(sticker) }))
        }
    }
    
    /* 설명 추가 */
    private func addTextSticker(text: String) {
        if let label = labelSticker.stickerView as? UILabel,
           let textArea = textSticker?.textView {
            label.text = text
            label.numberOfLines = 0
            let size = label.sizeThatFits(textArea.visibleSize)
            labelSticker.frame.size = CGSize(width: size.width + 36, height: size.height + 36)
            labelSticker.layoutIfNeeded()
        }
        let labelColor = labelSticker.sticker.value.hexColor
        labelSticker.sticker.accept(Sticker(type: .text, text: text, hexColor: labelColor))
        vm.removeSticker(labelSticker)
        if text.isEmpty {
            labelSticker.stickerView?.frame.size = CGSize.zero
            focusSticker = nil
            return
        }
        labelSticker.center = stickerPos[0]
        focusSticker = labelSticker
        vm.addSticker(labelSticker)
    }
    
    /* 텍스트 스티커 설정 */
    func configureTextSticker() {
        labelSticker.sticker.accept(Sticker(type: .text, text: "", hexColor: 0x000000))
        paintView.addSubview(labelSticker)
        
        // 스티커 삭제
        labelSticker.setLeftTopButton {
            self.textSticker?.textView.text = ""
            self.vm.removeSticker(self.labelSticker)
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
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        labelSticker.gestureRecognizers = [panGesture, tapGesture]
    }
    
    /* FocusSticker 변경 */
    func changeFocusSticker(_ view: UIView?) {
        guard let tappedSticker = view as? StickerEdgeView else { return }
        focusSticker = tappedSticker
    }
    
    /* 드래그 */
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        guard let focusView = focusSticker?.plainView,
              recognizer.view == focusView else { return }
        switch recognizer.state {
        case .began:
            lastPoint = focusView.center
        case .changed:
            let translation = recognizer.translation(in: view)
            focusView.center = CGPoint(x: lastPoint.x + translation.x,
                                       y: lastPoint.y + translation.y)
        default: break
        }
    }
    
    /* 선택 시 Focus 변경 */
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        changeFocusSticker(recognizer.view)
    }
    
    /* 회전 */
    @objc func handleRotateGesture(recognizer: UIRotationGestureRecognizer) {
        if recognizer.view != focusSticker?.plainView { return }
        if let rotationView = recognizer.view {
            rotationView.transform = rotationView.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0.0
        }
    }
    
    /* 크기 변경 */
    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        if recognizer.view != focusSticker?.plainView { return }
        if recognizer.state == .began {
            lastScale = recognizer.scale
        }
        guard let pinchView = recognizer.view else { return }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let currentScale = (pinchView.layer.value(forKeyPath: "transform.scale") as? NSNumber)?.floatValue
            let minScale: CGFloat = 0.5
            
            var newScale = 1.0 - (lastScale - recognizer.scale)
            if let currentScale = currentScale {
                newScale = max(newScale, minScale / (CGFloat)(currentScale))
                pinchView.transform = pinchView.transform.scaledBy(x: newScale, y: newScale)
                recognizer.scale = 1.0
                lastScale = recognizer.scale
            }
        }
    }
    
    /* 동시에 여러 제스쳐 허용 */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
