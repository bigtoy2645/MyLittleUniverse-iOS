//
//  InitVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/04/27.
//

import UIKit
import RxSwift

class InitVC: UIViewController, UIGestureRecognizerDelegate {
    let userName = Observable.of(Repository.instance.userName)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewDidAppear(animated)
        
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    /* Binding */
    func setupBindings() {
        userName.map { "반가워요\n\($0)님!" }
            .bind(to: lblName.rx.text)
            .disposed(by: disposeBag)
        
        // 등록 화면으로 이동
        btnRegister.rx.tap
            .bind {
                let registerVC = Route.getVC(.selectStatusVC)
                self.navigationController?.pushViewController(registerVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblName: UILabel!
}
