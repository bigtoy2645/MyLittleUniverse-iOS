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

struct Handler {
    let undo: (() -> Void)
    let redo: (() -> Void)
}

class PaintVC: UIViewController {
    static let storyboardID = "paintView"
    
    var emotion = Emotion.empty
    var stickers = [StickerEdgeView]()
    let labelSticker = StickerEdgeView()
    var bgColor = BehaviorRelay<Int>(value: 0xFFFFFF)
    var selectedControl: UIButton?
    var stickerIndex = 0
    var stickerPos: [CGPoint] = []
    var isBgColorSelected = false
    var focusSticker: StickerEdgeView? {
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
    
    private var undoFunctions: [Handler] = [] {
        didSet {
            DispatchQueue.main.async {
                let isUndoEnable = self.undoFunctions.count > 0
                self.btnUndo.isEnabled = isUndoEnable
                if let undoImage = UIImage(named: isUndoEnable ? "Undo-On_24" : "Undo-Off_24") {
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
                if let redoImage = UIImage(named: isRedoEnable ? "Redo-On_24" : "Redo-Off_24") {
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
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paintView.clipsToBounds = true
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
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
        bgColor.asObservable()
            .observe(on: MainScheduler.instance)
            .bind { hexColor in
                self.paintView.backgroundColor = UIColor(rgb: hexColor)
            }
            .disposed(by: disposeBag)
        
        // 색상 선택 완료
        btnDone.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                var buttonImage: UIImage?
                if self.focusSticker?.sticker.value.type == .picture {
                    buttonImage = UIImage(named: "edge/Edit-Off_24")
                } else {
                    buttonImage = UIImage(named: "edge/Color-Off_24")
                }
                
                if let buttonImage = buttonImage {
                    self.focusSticker?.changeButtonImage(buttonImage, position: .rightTop)
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
    
    /* 색상 선택 화면 표시 */
    func presentColorPicker(mode: ColorPickerMode) {
        if let colorVC = self.colorChips {
            present(asChildViewController: colorVC)
            colorPickerMode = mode
            if mode == .background {        // 기존 배경 색상 지정
                colorVC.selectedColor.onNext(bgColor.value)
            } else if mode == .sticker {    // 기존 스티커 색상 지정
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
    
    /* 색상 선택 화면 표시 */
    func presentClippingMask(image: UIImage?) {
        guard let clippingVC = clippingStickers else { return }
        
        clippingVC.originImage.onNext(image)
        present(asChildViewController: clippingVC)
        
        if let editOnImage = UIImage(named: "edge/Edit-On_24") {
            self.focusSticker?.changeButtonImage(editOnImage, position: .rightTop)
        }
        
        leftControls.isHidden = true
        rightControls.isHidden = false
        
        btnUndo.isHidden = true
        btnRedo.isHidden = true
        btnDone.isHidden = false
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
    
    /* 스티커 색상 변경 */
    private func updateStickerColor(stickerView: StickerEdgeView, hexColor: Int) {
        if let stickerIndex = stickers.firstIndex(of: stickerView) {
            var sticker = stickerView.sticker.value
            sticker.hexColor = hexColor
            stickerView.sticker.accept(sticker)
            self.stickers[stickerIndex] = stickerView
        }
    }
    
    /* 스티커 이미지 변경 */
    private func updateStickerImage(stickerView: StickerEdgeView, image: UIImage?) {
        if let stickerIndex = stickers.firstIndex(of: stickerView) {
            var sticker = stickerView.sticker.value
            sticker.image = image
            stickerView.sticker.accept(sticker)
            self.stickers[stickerIndex] = stickerView
        }
    }
    
    /* 색상 선택 */
    private func pickColor(_ hexColor: Int, isUndoAction: Bool = false) {
        if self.colorPickerMode == .background {    // 배경 색상 변경
            if isBgColorSelected {
                let oldHexColor = self.bgColor.value
                undoFunctions.append(Handler(undo: { self.bgColor.accept(oldHexColor) },
                                             redo: { self.bgColor.accept(hexColor) }))
            } else {
                isBgColorSelected = true
            }
            self.bgColor.accept(hexColor)
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
        guard let colorVC = self.storyboard?.instantiateViewController(withIdentifier: ColorChipVC.identifier) as? ColorChipVC else { return nil }
        colorVC.completeHandler = { (hexColor) in
            DispatchQueue.main.async {
                self.pickColor(hexColor)
                self.btnDone.isEnabled = true
            }
        }
        return colorVC
    }()
    
    private lazy var pictureStickers: PictureStickerVC? = {
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: PictureStickerVC.identifier) as? PictureStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.createSticker(Sticker(type: .picture, image: image)) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var clippingStickers: ClippingPictureStickerVC? = {
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: ClippingPictureStickerVC.identifier) as? ClippingPictureStickerVC else { return nil }
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
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: ShapeStickerVC.identifier) as? ShapeStickerVC else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.createSticker(Sticker(type: .shape, image: image)) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var textSticker: TextStickerVC? = {
        guard let textVC = self.storyboard?.instantiateViewController(withIdentifier: TextStickerVC.identifier) as? TextStickerVC else { return nil }
        textVC.emotion.accept(emotion)
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

extension PaintVC: UIGestureRecognizerDelegate {
    /* 스티커 생성 */
    private func createSticker(_ sticker: Sticker, centerPos: CGPoint? = nil, isUndoAction: Bool = false) {
        let imageSticker = StickerEdgeView()
        paintView.addSubview(imageSticker)
        
        // TODO - 32 -> 상대값
        let size = paintView.frame.width / 3 + 32
        imageSticker.frame.size = CGSize(width: size, height: size)
        imageSticker.center = centerPos ?? stickerPos[stickerIndex % stickerPos.count]
        imageSticker.contentMode = .scaleAspectFit
        imageSticker.sticker.accept(sticker)
        stickerIndex += 1
        
        // 스티커 삭제
        imageSticker.setLeftTopButton {
            self.removeSticker(imageSticker)
        }
        
        // 스티커 복제
        imageSticker.setLeftBottomButton {
            let centerPos = CGPoint(x: imageSticker.center.x + 26,
                                    y: imageSticker.center.y + 26)
            let cloneSticker = imageSticker.sticker.value
            self.createSticker(cloneSticker, centerPos: centerPos)
        }
        
        // 스티커 색상 변경
        if sticker.type == .shape {
            imageSticker.setRightTopButton {
                self.presentColorPicker(mode: .sticker)
            }
        } else if sticker.type == .picture {
            imageSticker.setRightTopButton(image: UIImage(named: "edge/Edit-Off_24")) {
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
        
        stickers.append(imageSticker)
        focusSticker = imageSticker
    }
    
    /* 스티커 추가 */
    func addSticker(_ sticker: StickerEdgeView) {
        paintView.addSubview(sticker)
        stickers.append(sticker)
        focusSticker = sticker
    }
    
    /* 스티커 삭제 */
    func removeSticker(_ sticker: StickerEdgeView, isUndoAction: Bool = false) {
        stickers = stickers.filter { $0.sticker.value != sticker.sticker.value }
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
        if let labelView = labelSticker.stickerView as? UILabel {
            labelView.sizeToFit()
            labelView.numberOfLines = text.components(separatedBy: "\n").count
            labelSticker.frame.size = CGSize(width: labelView.frame.width + 36,
                                             height: labelView.frame.height + 36)
        }
        labelSticker.sticker.accept(Sticker(type: .text, text: text, hexColor: 0x000000))
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
        guard let tappedSticker = view as? StickerEdgeView else { return }
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
