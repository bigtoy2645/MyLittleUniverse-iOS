//
//  TabBarView.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/29.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarView: UIView {
    var vc: UIViewController?
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadXib()
    }
    
    private func loadXib() {
        guard let view = Bundle.main.loadNibNamed("TabBarView",
                                                  owner: self,
                                                  options: nil)?.first as? UIView else { return }
        view.frame = self.bounds
        addSubview(view)
        
        setupBinding()
    }
    
    /* Binding */
    func setupBinding() {
        // 홈 화면으로 이동
        btnHome.rx.tap
            .bind {
                guard let vc = self.vc else { return }
                
                if let monthlyVC = vc as? MonthlyVC {
                    monthlyVC.scrollView.setContentOffset(.zero, animated: true)
                    return
                }
                
                guard let navigation = self.vc?.navigationController else { return }
                
                if navigation.viewControllers.filter({ $0 is MonthlyVC }).isEmpty {
                    navigation.pushViewController(Route.getVC(.monthlyVC), animated: false)
                } else {
                    _ = navigation.popToVC(MonthlyVC.self)
                }
            }
            .disposed(by: disposeBag)

        // 등록 화면으로 이동
        btnRegister.rx.tap
            .bind {
                guard let vc = self.vc else { return }
                let registerVC = Route.getVC(.selectStatusVC)
                vc.navigationController?.pushViewController(registerVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // 마이페이지로 이동
        btnMypage.rx.tap
            .bind {
                guard let vc = self.vc else { return }
                
                if let myPageVC = vc as? MyPageVC {
                    myPageVC.scrollView.setContentOffset(.zero, animated: true)
                    return
                }
                
                guard let navigation = self.vc?.navigationController else { return }
                
                if navigation.viewControllers.filter({ $0 is MyPageVC }).isEmpty {
                    navigation.pushViewController(Route.getVC(.myPageVC), animated: false)
                } else {
                    _ = navigation.popToVC(MyPageVC.self)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnMypage: UIButton!
}
