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
    var focusSticker: UIImageView? {
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
                    self.btnPicture.setImage(UIImage(named: "picture_on"), for: .normal)
                    self.btnShape.setImage(UIImage(named: "shape_off"), for: .normal)
                    self.btnText.setImage(UIImage(named: "text_off"), for: .normal)
                    self.present(asChildViewController: stickerVC)
                    stickerVC.type.onNext(.picture)
                }
            }
            .disposed(by: disposeBag)
        
        // 도형 스티커
        btnShape.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                if let stickerVC = self.stickerViewController {
                    self.btnShape.setImage(UIImage(named: "shape_on"), for: .normal)
                    self.btnPicture.setImage(UIImage(named: "picture_off"), for: .normal)
                    self.btnText.setImage(UIImage(named: "text_off"), for: .normal)
                    self.present(asChildViewController: stickerVC)
                    stickerVC.type.onNext(.shape)
                }
            }
            .disposed(by: disposeBag)
        
        // 텍스트
        btnText.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                //                if let stickerVC = self.stickerViewController {
                self.btnText.setImage(UIImage(named: "text_on"), for: .normal)
                self.btnShape.setImage(UIImage(named: "shape_off"), for: .normal)
                self.btnPicture.setImage(UIImage(named: "picture_off"), for: .normal)
                //                    self.add(asChildViewController: stickerVC)
                //                    stickerVC.type.onNext(.shape)
                //                }
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
    
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        focusSticker?.center = recognizer.location(in: paintView)
    }
    
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        guard let tappedImage = recognizer.view as? UIImageView else { return }
        focusSticker = tappedImage
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
    
    /* 스티커 추가 */
    private func addSticker(image: UIImage) {
        let sticker = UIImageView(image: image)
        
        let size = self.paintView.frame.width / 4
        sticker.frame.size = CGSize(width: size, height: size)
        sticker.center = self.paintView.center
        
        // Gesture
        sticker.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handlePanGesture(recognizer:)))
        sticker.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTapGesture(recognizer:)))
        sticker.addGestureRecognizer(tapGesture)
        
        self.stickers.append(sticker)
        self.paintView.addSubview(sticker)
        self.focusSticker = sticker
    }
    
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
    @IBOutlet weak var btnShape: UIButton!
    @IBOutlet weak var btnText: UIButton!
}
