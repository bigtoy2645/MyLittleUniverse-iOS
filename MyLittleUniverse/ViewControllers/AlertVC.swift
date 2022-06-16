//
//  AlertViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/07.
//

import UIKit
import RxSwift
import RxCocoa

class AlertVC: UIViewController {
    var vm = AlertViewModel()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 4
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        let alert = vm.alert.asDriver()
        
        // 타이틀
        alert.map { $0.title }
            .drive(lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        // 서브타이틀
        alert.map { $0.subtitle }
            .drive(lblSubtitle.rx.text)
            .disposed(by: disposeBag)
        
        // 서브타이틀 숨김 여부
        vm.hideSubtitle
            .observe(on: MainScheduler.instance)
            .bind(to: lblSubtitle.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 이미지
        vm.image
            .observe(on: MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        // 이미지 숨김
        vm.hideImage
            .observe(on: MainScheduler.instance)
            .bind(to: imageView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 버튼 사용 여부
        vm.hideButtons
            .observe(on: MainScheduler.instance)
            .bind { isHidden in
                self.buttons.isHidden = isHidden
                self.bottomConstraint.constant = isHidden ? 24 : 8
            }
            .disposed(by: disposeBag)
        
        // 실행 버튼
        alert.map { $0.runButtonTitle }
            .drive(btnRun.rx.title())
            .disposed(by: disposeBag)
        
        // 실행 버튼 숨김
        vm.hideRunButton
            .observe(on: MainScheduler.instance)
            .bind(to: btnRun.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 취소 버튼
        alert.map { $0.cancelButtonTitle }
            .drive(btnCancel.rx.title())
            .disposed(by: disposeBag)
        
        // 취소 버튼 숨김
        vm.hideCancelButton
            .observe(on: MainScheduler.instance)
            .bind(to: btnCancel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    /* 실행 버튼 */
    func addRunButton(color: UIColor? = UIColor.errorRed,
                      tapEvent: @escaping () -> ()) {
        DispatchQueue.main.async {
            self.btnRun.setTitleColor(color, for: .normal)
            self.btnRun.rx.tap
                .bind {
                    tapEvent()
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    /* 취소 버튼 */
    func addCancelButton(color: UIColor? = UIColor.mainBlack,
                         tapEvent: @escaping () -> ()) {
        DispatchQueue.main.async {
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
