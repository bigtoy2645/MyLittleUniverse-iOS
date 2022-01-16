//
//  HomeViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/14.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    static let storyboardID = "homeView"
    
    let viewModel = MomentViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnMainStatus.layer.borderWidth = 1
        btnMainStatus.layer.cornerRadius = 15
        btnMainStatus.layer.borderColor = btnMainStatus.currentTitleColor.cgColor
        
        btnMainStatus.rx.tap
            .bind {
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: DetailViewController.storyboardID) as? DetailViewController else { return }
                detailVC.modalPresentationStyle = .fullScreen
                self.present(detailVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var btnMainStatus: UIButton!
}
