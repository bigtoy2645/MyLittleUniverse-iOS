//
//  HomeViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/14.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController, UIScrollViewDelegate {
    static let storyboardID = "homeView"
    
    let viewModel = MomentViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnMainEmotion.layer.borderWidth = 1
        btnMainEmotion.layer.cornerRadius = 15
        btnMainEmotion.layer.borderColor = btnMainEmotion.currentTitleColor.cgColor
        tabView.layer.cornerRadius = 10
        
        scrollView.delegate = self
        
        setupBindings()
        
        guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: SelectEmotionViewController.storyboardID) else { return }
        self.navigationController?.pushViewController(registerVC, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    /* 스크롤 시 탭바 표시 */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tabView.hideWithAnimation(hidden: false)
    }
    
    /* 스크롤 중단 시 탭바 숨기기 */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.tabView.hideWithAnimation(hidden: true)
        }
    }
    
    /* Binding */
    func setupBindings() {
        // 홈 화면으로 이동
        btnHome.rx.tap
            .bind {
                self.scrollView.setContentOffset(.zero, animated: true)
            }
            .disposed(by: disposeBag)
        
        // 등록 화면으로 이동
        btnRegister.rx.tap
            .bind {
                guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: SelectEmotionViewController.storyboardID) else { return }
                self.navigationController?.pushViewController(registerVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // 마이페이지로 이동
        btnMypage.rx.tap
            .bind {
            }
            .disposed(by: disposeBag)
        
        // 이 달 제일 많이 등록된 감정
        btnMainEmotion.rx.tap
            .bind {
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: DetailViewController.storyboardID) as? DetailViewController else { return }
                
                self.viewModel.allMoments
                    .subscribe(onNext: detailVC.moments.onNext)
                    .disposed(by: self.disposeBag)
                
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var btnMainEmotion: UIButton!
    
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnMypage: UIButton!
}
