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
    var focusSticker = UIImageView()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        btnAddBgColor.rx.tap
            .bind {
                self.stackBackground.isHidden = true
                if let stickerVC = self.stickerViewController {
                    self.add(asChildViewController: stickerVC)
                    
                    self.rightControls.isHidden = false
                    self.btnUndo.isHidden = true
                    self.btnRedo.isHidden = true
                    self.btnDone.isHidden = false
                }
            }
            .disposed(by: disposeBag)
        
        btnDone.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                self.btnDone.isHidden = true
                self.leftControls.isHidden = false
                self.btnUndo.isHidden = false
                self.btnRedo.isHidden = false
            }
            .disposed(by: disposeBag)
        
        //        btnTriangle.rx.tap
        //            .bind {
        //                let imageView = UIImageView(image: self.btnTriangle.currentBackgroundImage)
        //                imageView.frame.origin = CGPoint(x: 50, y: 100)
        //                let width = self.paintView.frame.width / 3
        //                imageView.frame.size = CGSize(width: width, height: width)
        //                imageView.layer.borderWidth = 1
        //                imageView.layer.borderColor = UIColor.gray.cgColor
        //                imageView.isUserInteractionEnabled = true
        //                let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(recognizer:)))
        //                imageView.addGestureRecognizer(pan)
        //
        //                self.stickers.append(imageView)
        //
        ////                self.stickers.map { self.paintView.addSubview($0) }
        //            }
        //            .disposed(by: disposeBag)
    }
    
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        //        NSLog("handlePanGesture \(stickers.center)")
        //        stickers.center = recognizer.location(in: paintView)
    }
    
    private lazy var stickerViewController: PaintStickerViewController? = {
        guard let stickerVC = self.storyboard?.instantiateViewController(withIdentifier: PaintStickerViewController.identifier) as? PaintStickerViewController else { return nil }
        stickerVC.completeHandler = { (color) in
            DispatchQueue.main.async {
                self.paintView.backgroundColor = color
                self.btnDone.isEnabled = true
                self.btnDone.alpha = 1.0
            }
        }
        
        add(asChildViewController: stickerVC)
        return stickerVC
    }()
    
    private func add(asChildViewController viewController: UIViewController) {
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
    @IBOutlet weak var paintView: UIView!
    @IBOutlet weak var stickerView: UIView!
    @IBOutlet weak var leftControls: UIStackView!
    @IBOutlet weak var rightControls: UIStackView!
    
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnDone: UIButton!
}
