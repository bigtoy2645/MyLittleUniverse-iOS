//
//  MonthlyVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa

class MonthlyVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    static let storyboardID = "homeView"
    
    let viewModel = MonthlyViewModel(date: Date())
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnMainEmotion.titleEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        btnMainEmotion.layer.borderWidth = 1
        btnMainEmotion.layer.cornerRadius = 13
        btnMainEmotion.layer.borderColor = btnMainEmotion.currentTitleColor.cgColor
        tabView.addShadow(location: .top)
        
        scrollView.delegate = self
        
        setupBindings()
        
        // 감정 등록 화면으로 이동
        guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: SelectStatusVC.storyboardID) else { return }
        self.navigationController?.pushViewController(registerVC, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .light
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ranking 타원 그리기
        rankingView.layoutSubviews()
        for ranking in rankingView.arrangedSubviews {
            let path = UIBezierPath(ovalIn: ranking.bounds)
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = ranking.backgroundColor?.cgColor
            layer.fillMode = .forwards
            ranking.layer.insertSublayer(layer, at: 0)
            ranking.backgroundColor = .clear
        }
    }
    
    /* Binding */
    func setupBindings() {
        tabViewBinding()
        rankingBinding()
        
        // 이 달 제일 많이 등록된 감정
        viewModel.emotions
            .map { $0.sorted { $0.1 > $1.1 }[0].key.rawValue }
            .bind(to: btnMainEmotion.rx.title())
            .disposed(by: disposeBag)
        
        btnMainEmotion.rx.tap
            .bind {
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: MonthlyEmotionVC.storyboardID) as? MonthlyEmotionVC,
                      let btnTitle = self.btnMainEmotion.title(for: .normal),
                      let emotion = Emotion(rawValue: btnTitle) else { return }
                detailVC.viewModel = MonthlyEmotionViewModel(date: Date(), emotion: emotion)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        // 날짜별 감정
        colDays.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.of(Array(1...31))
            .bind(to: colDays.rx.items(cellIdentifier: DayChipCell.identifier,
                                          cellType: DayChipCell.self)) { index, day, cell in
                cell.lblDay.text = "\(day)"
                // TODO - true/false
//                cell.isRecorded = self.viewModel.recoredDays.map {
//                    cell.isRecorded = $0.contains(day)
//                }
            }
            .disposed(by: disposeBag)
        
        colDays.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
//                if let cell = self.colDays.cellForItem(at: index) as? DayChipCell {
//                }
            })
            .disposed(by: disposeBag)
    }
    
    /* tabView Binding */
    func tabViewBinding() {
        // 홈 화면으로 이동
        btnHome.rx.tap
            .bind {
                self.scrollView.setContentOffset(.zero, animated: true)
            }
            .disposed(by: disposeBag)
        
        // 등록 화면으로 이동
        btnRegister.rx.tap
            .bind {
                guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: SelectStatusVC.storyboardID) else { return }
                self.navigationController?.pushViewController(registerVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // TODO - 마이페이지로 이동
        btnMypage.rx.tap
            .bind {
            }
            .disposed(by: disposeBag)
    }
    
    func rankingBinding() {
        viewModel.emotions
            .map { $0.sorted { $0.1 > $1.1 } }
            .bind { ranking in
                _ = self.rankingView.arrangedSubviews.map { $0.isHidden = true }
                
                if ranking.count > 0 {
                    self.lblRanking1.text = ranking[0].key.rawValue
                    self.lblRanking1Days.text = "\(ranking[0].value) days"
                    self.rankingView.arrangedSubviews[0].isHidden = false
                }
                
                if ranking.count > 1 {
                    self.lblRanking2.text = ranking[1].key.rawValue
                    self.lblRanking2Days.text = "\(ranking[1].value) days"
                    self.rankingView.arrangedSubviews[1].isHidden = false
                }
                
                if ranking.count > 2 {
                    self.lblRanking3.text = ranking[2].key.rawValue
                    self.rankingView.arrangedSubviews[2].isHidden = false
                }
                
                if ranking.count > 3 {
                    self.lblRanking4.text = ranking[3].key.rawValue
                    self.rankingView.arrangedSubviews[3].isHidden = false
                }
                
                if ranking.count > 4 {
                    self.rankingView.arrangedSubviews[4].isHidden = false
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tabView: UIView!
    
    @IBOutlet weak var btnMainEmotion: UIButton!
    @IBOutlet weak var mainEmotionWidth: NSLayoutConstraint!
    
    @IBOutlet weak var rankingView: UIStackView!
    @IBOutlet weak var lblRanking1: UILabel!
    @IBOutlet weak var lblRanking1Days: UILabel!
    @IBOutlet weak var lblRanking2: UILabel!
    @IBOutlet weak var lblRanking2Days: UILabel!
    @IBOutlet weak var lblRanking3: UILabel!
    @IBOutlet weak var lblRanking4: UILabel!
    
    @IBOutlet weak var colDays: UICollectionView!
    @IBOutlet weak var colMomentsOfDay: UICollectionView!
    
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnMypage: UIButton!
}

// MARK: - UIScrollViewDelegate

extension MonthlyVC: UIScrollViewDelegate {
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
}
