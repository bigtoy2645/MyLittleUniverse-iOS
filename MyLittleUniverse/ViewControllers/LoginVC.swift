//
//  LoginVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/09/18.
//

import UIKit
import RxSwift

class LoginVC: UIViewController, UIGestureRecognizerDelegate {
    let appleLogin = AppleLogin()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = self
                
        stackEnter.insertArrangedSubview(appleLogin.button, at: 0)
        appleLogin.configure {
            // 기존 사용자 : 연결 완료 후, 등록 화면으로 이동
            // 신규 사용자 : 연결 완료 후, 이름 설정 화면으로 이동
            let nextVC = Route.getVC(.nameVC)
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
        
        setupBindings()
        
        if Repository.instance.isLogin.value {
            let nextVC = Route.getVC(.nameVC)
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.overrideUserInterfaceStyle = .dark
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    /* Binding */
    func setupBindings() {
        btnGuest.rx.tap
            .bind {
                let selectVC = Route.getVC(.selectStatusVC)
                self.navigationController?.pushViewController(selectVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    @IBOutlet weak var stackEnter: UIStackView!
    @IBOutlet weak var btnGuest: UIButton!
}
