//
//  AlertViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/07.
//

import UIKit
import RxSwift
import RxCocoa

class AlertViewController: UIViewController {
    static let storyboardID = "alertView"
    
    var alertTitle = BehaviorRelay<String>(value: "")
    var alertSubtitle = BehaviorRelay<String?>(value: nil)
    var alertImage = BehaviorRelay<UIImage?>(value: nil)
    var runButtonTitle = BehaviorRelay<String?>(value: nil)
    var cancelButtonTitle = BehaviorRelay<String?>(value: nil)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 4
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        // 타이틀
        alertTitle
            .bind(to: lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        // 서브타이틀
        alertSubtitle
            .bind(to: lblSubtitle.rx.text)
            .disposed(by: disposeBag)
        
        alertSubtitle
            .map { subtitle in subtitle?.isEmpty ?? true }
            .bind(to: lblSubtitle.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 이미지
        alertImage
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        alertImage
            .map { image in image == nil }
            .bind(to: imageView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 버튼 사용 여부
        Observable.combineLatest(runButtonTitle, cancelButtonTitle)
            .map { runTitle, cancelTitle -> Bool in
                let runButtonIsEmpty = runTitle?.isEmpty ?? true
                let cancelButtonIsEmpty = cancelTitle?.isEmpty ?? true
                return runButtonIsEmpty && cancelButtonIsEmpty
            }
            .bind { isHidden in
                self.buttons.isHidden = isHidden
                self.bottomConstraint.constant = isHidden ? 24 : 8
            }
            .disposed(by: disposeBag)
        
        // 실행 버튼
        runButtonTitle
            .bind(to: btnRun.rx.title())
            .disposed(by: disposeBag)
        
        runButtonTitle
            .map({ title in title?.isEmpty ?? true })
            .bind(to: btnRun.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 취소 버튼
        cancelButtonTitle
            .bind(to: btnCancel.rx.title())
            .disposed(by: disposeBag)
        
        cancelButtonTitle
            .map({ title in title?.isEmpty ?? true })
            .bind(to: btnCancel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    /* 실행 버튼 */
    func addRunButton(title: String,
                      color: UIColor? = UIColor.errorRed,
                      tapEvent: @escaping () -> ()) {
        DispatchQueue.main.async {
            self.runButtonTitle.accept(title)
            self.btnRun.setTitleColor(color, for: .normal)
            self.btnRun.rx.tap
                .bind {
                    tapEvent()
                }
                .disposed(by: self.disposeBag)
        }
        
    }
    
    /* 취소 버튼 */
    func addCancelButton(title: String,
                         color: UIColor? = UIColor.mainBlack,
                         tapEvent: @escaping () -> ()) {
        DispatchQueue.main.async {
            self.cancelButtonTitle.accept(title)
            self.btnCancel.rx.tap
                .bind {
                    tapEvent()
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttons: UIStackView!
    @IBOutlet weak var btnRun: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
}
