//
//  NewMonthVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/09/17.
//

import UIKit
import RxSwift

class NewMonthVC: UIViewController, UIGestureRecognizerDelegate {
    let userName = Observable.of(Repository.instance.userName)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        
        tabView.addShadow(location: .top)
        tabView.vc = self
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        btnLastMonth.titleLabel?.setUnderline(range: NSRange(location: 0, length: btnLastMonth.currentTitle?.count ?? 0))
        
        // 이전 달 정보 삭제
        let monthlyMoments = Repository.instance.monthlyMoments.value
        Repository.instance.moments.accept(monthlyMoments)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        goView.layer.cornerRadius = goView.bounds.width / 2
    }
    
    /* Binding */
    func setupBindings() {
        userName.map { "\($0)님,\n안녕하세요!" }
            .bind(to: lblName.rx.text)
            .disposed(by: disposeBag)
        
        userName.map { "지난 달은 어떤 감정이 있었는지 궁금하지 않나요?\n오늘을 기록하고 계속해서 \($0)님의 세계를 넓혀가요!" }
            .bind(to: lblDescription.rx.text)
            .disposed(by: disposeBag)
        
        goView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                let registerVC = Route.getVC(.selectStatusVC)
                self.navigationController?.pushViewController(registerVC, animated: false)
            })
            .disposed(by: self.disposeBag)
        
        // 마이페이지 지난달 달력으로 이동
        btnLastMonth.rx.tap
            .bind {
                self.tabView.btnMypage.sendActions(for: .touchUpInside)
                if let myPageVC = self.navigationController?.searchVC(MyPageVC.self) as? MyPageVC {
                    myPageVC.isLastMonth = true
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var goView: UIView!
    @IBOutlet weak var btnLastMonth: UIButton!
    @IBOutlet weak var tabView: TabBarView!
}
