//
//  PaintViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/22.
//

import UIKit
import RxSwift

class PaintViewController: UIViewController {
    static let storyboardID = "paintView"
    
    var stickers = [UIImageView]()
    var lblText = UILabel()
    var focusSticker: UIView? {
        didSet {
            oldValue?.layer.borderWidth = 0
            focusSticker?.layer.borderWidth = 1
            focusSticker?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
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
                self.presentBackgroundColorChipView()
                self.btnDone.isEnabled = false
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 변경
        btnEditBgColor.rx.tap
            .bind {
                self.presentBackgroundColorChipView()
                self.btnDone.isEnabled = true
            }
            .disposed(by: disposeBag)
        
        // 배경 색상 선택 완료
        btnDone.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                self.presentStickerView()
            }
            .disposed(by: disposeBag)
        
        // 그림 스티커
        btnPicture.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if let stickerVC = self.stickerViewController {
                    self.selectButton(item: self.btnPicture)
                    self.present(asChildViewController: stickerVC)
                    stickerVC.type.onNext(.picture)
                }
            }
            .disposed(by: disposeBag)
        
        // 라인 도형 스티커
        btnLineShape.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if let stickerVC = self.stickerViewController {
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
                if let stickerVC = self.stickerViewController {
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
                if let textVC = self.textViewController {
                    self.selectButton(item: self.btnText)
                    self.present(asChildViewController: textVC)
                }
            }
            .disposed(by: disposeBag)
    }
    
    /* 배경 색상 선택 화면 표시 */
    func presentBackgroundColorChipView() {
        if let colorVC = self.colorChipViewController {
            present(asChildViewController: colorVC)
            
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
        
        btnPicture.sendActions(for: .touchUpInside)
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
    
    private lazy var colorChipViewController: PaintColorChipViewController? = {
        guard let colorVC = self.storyboard?.instantiateViewController(withIdentifier: PaintColorChipViewController.identifier) as? PaintColorChipViewController else { return nil }
        colorVC.completeHandler = { (color) in
            DispatchQueue.main.async {
                self.paintView.backgroundColor = color
                self.btnDone.isEnabled = true
            }
        }
        
        return colorVC
    }()
    
    private lazy var stickerViewController: PaintStickerViewController? = {
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: PaintStickerViewController.identifier) as? PaintStickerViewController else { return nil }
        stickerVC.completeHandler = { (image) in
            DispatchQueue.main.async {
                if let image = image { self.addSticker(image: image) }
            }
        }
        
        return stickerVC
    }()
    
    private lazy var textViewController: PaintTextViewController? = {
        guard let textVC = self.storyboard?.instantiateViewController(withIdentifier: PaintTextViewController.identifier) as? PaintTextViewController else { return nil }
        textVC.completeHandler = { (description) in
            DispatchQueue.main.async {
                self.addTextSticker(text: description)
            }
        }
        
        return textVC
    }()
    
    private func present(asChildViewController viewController: UIViewController) {
        if stickerView.subviews.contains(viewController.view) {
            stickerView.bringSubviewToFront(viewController.view)
            return
        }
        
        addChild(viewController)
        stickerView.addSubview(viewController.view)
        
        viewController.view.frame = stickerView.bounds
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
    @IBOutlet weak var stickerView: UIView!
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

extension PaintViewController {
    /* 스티커 추가 */
    private func addSticker(image: UIImage) {
        let sticker = UIImageView(image: image)
        
        let size = paintView.frame.width / 4
        sticker.frame.size = CGSize(width: size, height: size)
        sticker.center = paintView.center
        
        // Gesture
        sticker.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        sticker.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTapGesture(recognizer:)))
        sticker.addGestureRecognizer(tapGesture)
        
        stickers.append(sticker)
        paintView.addSubview(sticker)
        focusSticker = sticker
    }
    
    /* 설명 추가 */
    private func addTextSticker(text: String) {
        lblText.text = text
        if text.isEmpty {
            lblText.frame.size = CGSize.zero
            return
        }
        lblText.sizeToFit()
        lblText.numberOfLines = text.components(separatedBy: "\n").count
        lblText.frame.size = CGSize(width: lblText.frame.width + 20,
                                    height: lblText.frame.height + 20)
        lblText.center = paintView.center
        focusSticker = lblText
        
        if paintView.subviews.contains(lblText) { return }
        
        // Gesture
        lblText.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        lblText.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTapGesture(recognizer:)))
        lblText.addGestureRecognizer(tapGesture)
        lblText.textAlignment = .center
        lblText.lineBreakMode = .byClipping
        
        paintView.addSubview(lblText)
    }
    
    /* 드래그 */
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        focusSticker?.center = recognizer.location(in: paintView)
    }
    
    /* 선택 시 Focus 변경 */
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        guard let tappedImage = recognizer.view as? UIImageView else { return }
        focusSticker = tappedImage
    }
}
