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
                // Color Chips
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
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var stackBackground: UIStackView!
    @IBOutlet weak var btnAddBgColor: UIButton!
    @IBOutlet weak var paintView: UIView!
}
