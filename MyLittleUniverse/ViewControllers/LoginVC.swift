//
//  LoginVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/09/18.
//

import UIKit
import RxSwift

class LoginVC: UIViewController {
    let appleLogin = AppleLogin()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackEnter.insertArrangedSubview(appleLogin.button, at: 0)
        appleLogin.configure {
            // 다음 화면 표시
        }
    }
    
    @IBOutlet weak var stackEnter: UIStackView!
    @IBOutlet weak var btnGuest: UIButton!
}
