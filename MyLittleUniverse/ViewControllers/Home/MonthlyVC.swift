//
//  MonthlyVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa

class MonthlyVC: UIViewController {
    let viewModel = MonthlyViewModel(date: Date())
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnMainEmotion.layer.borderWidth = 1
        btnMainEmotion.layer.cornerRadius = 13
        btnMainEmotion.layer.borderColor = btnMainEmotion.currentTitleColor.cgColor
        tabView.addShadow(location: .top)
        
        scrollView.delegate = self
        
        setupBindings()
        
        // 감정 등록 화면으로 이동
        let registerVC = Route.getVC(.selectStatusVC)
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
        viewModel.mainEmotion.map { $0.word }
            .bind(to: btnMainEmotion.rx.title())
            .disposed(by: disposeBag)
        
        btnMainEmotion.rx.tap
            .bind { self.presentMonthlyView(emotion: self.viewModel.mainEmotion.value) }
            .disposed(by: disposeBag)
        
        // 날짜별 감정
        colDays.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        colMomentsOfDay.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.of(Array(1...31))
            .bind(to: colDays.rx.items(cellIdentifier: DayChipCell.identifier,
                                          cellType: DayChipCell.self)) { index, day, cell in
                cell.lblDay.text = String(day)
                let isRecorded = self.viewModel.recoredDays.value.contains(day)
                cell.isSelected = (self.viewModel.selectedDay.value == index)
                cell.isRecorded.accept(isRecorded)
            }
            .disposed(by: disposeBag)
        
        colDays.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                self.viewModel.selectedDay.accept(index.row)
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedMoments
            .bind(to: colMomentsOfDay.rx.items(cellIdentifier: DayMomentCell.identifier,
                                               cellType: DayMomentCell.self)) { index, moment, cell in
                cell.moment.accept(moment)
            }
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
                let registerVC = Route.getVC(.selectStatusVC)
                self.navigationController?.pushViewController(registerVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // TODO - 마이페이지로 이동
        btnMypage.rx.tap
            .bind {
            }
            .disposed(by: disposeBag)
    }
    
    /* 랭킹 Binding */
    func rankingBinding() {
        viewModel.ranking0
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[0]
                self.lblRanking0.text = ranking.emotion.word
                self.lblRanking0Days.text = "\(ranking.count) days"
                
                rankingView.rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.presentMonthlyView(emotion: ranking.emotion)
                    })
                    .disposed(by: self.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        viewModel.ranking1
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[1]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
                self.lblRanking1.text = ranking.emotion.word
                self.lblRanking1Days.text = "\(ranking.count) days"
                
                rankingView.rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.presentMonthlyView(emotion: ranking.emotion)
                    })
                    .disposed(by: self.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        viewModel.ranking2
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[2]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
                self.lblRanking2.text = ranking.emotion.word
                
                rankingView.rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.presentMonthlyView(emotion: ranking.emotion)
                    })
                    .disposed(by: self.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        viewModel.ranking3
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[3]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
                self.lblRanking1.text = ranking.emotion.word
                
                rankingView.rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.presentMonthlyView(emotion: ranking.emotion)
                    })
                    .disposed(by: self.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        viewModel.rankings
            .bind { emotions in
                self.rankingView.arrangedSubviews[4].isHidden = emotions.count <= 4
            }
            .disposed(by: disposeBag)
    }
    
    /* 이달의 발견 세부 화면 표시 */
    func presentMonthlyView(emotion: Emotion) {
        guard let detailVC = Route.getVC(.monthlyEmotionVC) as? MonthlyEmotionVC else { return }
        detailVC.viewModel = MonthlyEmotionViewModel(date: Date(), emotion: emotion)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tabView: UIView!
    
    @IBOutlet weak var btnMainEmotion: UIButton!
    
    @IBOutlet weak var rankingView: UIStackView!
    @IBOutlet weak var lblRanking0: UILabel!
    @IBOutlet weak var lblRanking0Days: UILabel!
    @IBOutlet weak var lblRanking1: UILabel!
    @IBOutlet weak var lblRanking1Days: UILabel!
    @IBOutlet weak var lblRanking2: UILabel!
    @IBOutlet weak var lblRanking3: UILabel!
    
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

// MARK: - UICollectionView

extension MonthlyVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colMomentsOfDay {
            let width = (view.frame.width - 75) / 2.0
            let height = width * 4 / 3
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 30, height: 30)
    }
}
