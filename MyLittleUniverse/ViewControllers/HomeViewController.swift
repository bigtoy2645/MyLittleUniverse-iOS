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
                
                self.viewModel.allMoments
                    .subscribe(onNext: detailVC.moments.onNext)
                    .disposed(by: self.disposeBag)
                
                self.navigationController?.pushViewController(detailVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let todayVC = self.storyboard?.instantiateViewController(withIdentifier: TodayViewController.storyboardID) else { return }
        self.navigationController?.pushViewController(todayVC, animated: false)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var btnMainStatus: UIButton!
}
