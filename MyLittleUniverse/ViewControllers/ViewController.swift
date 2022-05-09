//
//  ViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/09.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogin.layer.cornerRadius = 10
        txtID.layer.cornerRadius = 10
        txtPwd.layer.cornerRadius = 10
        
        lblTitle.attributedText = NSMutableAttributedString(string: "MY\nLITTLE\nUNIVERSE", attributes: nil)
        
        // Login
        btnLogin.rx.tap
            .bind {
                let nextViewId: Route.ViewId = Repository.instance.moments.value.isEmpty ? .initVC : .monthlyVC
                let nextVC = Route.getVC(nextViewId)
                self.navigationController?.pushViewController(nextVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var txtID: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
}

