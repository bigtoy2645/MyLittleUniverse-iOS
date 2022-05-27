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
    let viewModel = MonthlyViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblUserName.text = "\(Repository.instance.userName)님의"
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 선택한 날짜 가운데로 스크롤
        let dayIndex = IndexPath(row: viewModel.selectedIndex.value, section: 0)
        colDays.selectItem(at: dayIndex,
                           animated: true,
                           scrollPosition: .centeredHorizontally)
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
            .bind { self.presentMonthlyView(0) }
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
                let isRecorded = self.viewModel.recordedDays.value.contains(day)
                cell.isSelected = (self.viewModel.selectedIndex.value == index)
                cell.isRecorded.accept(isRecorded)
            }
                                       .disposed(by: disposeBag)
        
        colDays.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                self.viewModel.selectedIndex.accept(index.row)
            })
            .disposed(by: disposeBag)
        
        colMomentsOfDay.rx.willDisplayCell
            .subscribe(onNext: { _ in
                var height = self.colMomentsOfDay.contentSize.height
                if height <= 0 { height = self.momentsHeight.constant }
                self.momentsHeight.constant = height
                self.view.layoutIfNeeded()
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
        
        // 마이페이지로 이동
        btnMypage.rx.tap
            .bind {
                let myPageVC = Route.getVC(.myPageVC)
                self.navigationController?.pushViewController(myPageVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    /* 랭킹 Binding */
    func rankingBinding() {
        viewModel.rankings.map { $0[0] }
            .bind { ranking in
                self.lblRanking0.text = ranking.emotion.word
                self.lblRanking0Days.text = "\(ranking.count) days"
            }
            .disposed(by: disposeBag)
        
        viewModel.rankings.map { $0[safe: 1] }
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[1]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
                self.lblRanking1.text = ranking.emotion.word
                self.lblRanking1Days.text = "\(ranking.count) days"
            }
            .disposed(by: disposeBag)
        
        viewModel.rankings.map { $0[safe: 2] }
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[2]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
                self.lblRanking2.text = ranking.emotion.word
            }
            .disposed(by: disposeBag)
        
        viewModel.rankings.map { $0[safe: 3] }
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[3]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
                self.lblRanking3.text = ranking.emotion.word
            }
            .disposed(by: disposeBag)
        
        viewModel.rankings
            .bind { emotions in
                self.rankingView.arrangedSubviews[4].isHidden = emotions.count <= 4
            }
            .disposed(by: disposeBag)
        
        for rankingIndex in 0..<4 {
            if let subview = rankingView.arrangedSubviews[safe: rankingIndex] {
                subview.rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in self.presentMonthlyView(rankingIndex) })
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
    /* 이달의 발견 세부 화면 표시 */
    func presentMonthlyView(_ index: Int) {
        guard let detailVC = Route.getVC(.monthlyEmotionVC) as? MonthlyEmotionVC,
              let emotionCount = viewModel.rankings.value[safe: index] else { return }
        
        detailVC.viewModel = MonthlyEmotionViewModel(emotion: emotionCount.emotion)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tabView: UIView!
    
    @IBOutlet weak var lblUserName: UILabel!
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
    @IBOutlet weak var momentsHeight: NSLayoutConstraint!
    
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
