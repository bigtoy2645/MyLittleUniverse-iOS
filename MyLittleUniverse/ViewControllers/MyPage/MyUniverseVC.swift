//
//  MyUniverseVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/22.
//

import UIKit
import RxSwift
import RxCocoa

class MyUniverseVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tblWords: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    /* Binding */
    func setupBindings() {
        btnBack.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
