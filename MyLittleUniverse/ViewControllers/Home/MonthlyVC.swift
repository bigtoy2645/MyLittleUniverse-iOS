//
//  MonthlyVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/14.
//

import UIKit
import RxSwift
import RxCocoa

class MonthlyVC: UIViewController, UIGestureRecognizerDelegate {
    let viewModel = MonthlyViewModel()
    private var cardVC: CardVC?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblUserName.text = "\(Repository.instance.userName)님의"
        btnMainEmotion.layer.borderWidth = 1
        btnMainEmotion.layer.cornerRadius = 13
        btnMainEmotion.layer.borderColor = btnMainEmotion.currentTitleColor.cgColor
        tabView.addShadow(location: .top)
        tabView.vc = self
        imgBubble.addShadow(location: .bottom,
                            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25),
                            opacity: 1.0,
                            radius: 8)
        
        scrollView.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if let cardVC = Route.getVC(.cardVC) as? CardVC {
            self.cardVC = cardVC
            self.present(asChildViewController: cardVC, view: cardView)
        }
        
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.setContentOffset(.zero, animated: false)
        
        viewModel.selectedIndex.accept(viewModel.selectedIndex.value)
        
        if viewModel.rankings.value.count > 2 {
            tabView.transform = CGAffineTransform(translationX: 0, y: self.tabView.frame.height)
        } else {
            tabView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 선택한 날짜 가운데로 스크롤
        let dayIndex = IndexPath(row: viewModel.selectedIndex.value, section: 0)
        colDays.selectItem(at: dayIndex,
                           animated: true,
                           scrollPosition: .centeredHorizontally)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // 말풍선 애니메이션
        if !bubbleView.isHidden {
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.bubbleView.transform = CGAffineTransform(translationX: 0, y: 10)
            }) { _ in
                self.bubbleView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    /* Binding */
    func setupBindings() {
        rankingBinding()
        
        // 이 달 제일 많이 등록된 감정
        viewModel.mainEmotion.map { $0.word }
            .bind(to: btnMainEmotion.rx.title())
            .disposed(by: disposeBag)
        
        btnMainEmotion.rx.tap
            .bind { self.presentMonthlyView(0) }
            .disposed(by: disposeBag)
        
        // 날짜별 감정
        viewModel.monthString
            .bind(to: lblMonth.rx.text)
            .disposed(by: disposeBag)
        
        colDays.rx
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
        
        viewModel.selectedMoments
            .bind { self.cardVC?.moments.accept($0) }
            .disposed(by: disposeBag)
        
        cardVC?.height
            .bind(to: cardViewHeight.rx.constant)
            .disposed(by: disposeBag)
    }
    
    /* 랭킹 Binding */
    func rankingBinding() {
        viewModel.rankings.map { $0[safe: 0] }
            .bind { ranking in
                let rankingView = self.rankingView.arrangedSubviews[0]
                guard let ranking = ranking else {
                    rankingView.isHidden = true
                    return
                }
                rankingView.isHidden = false
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
        
        viewModel.rankings.map { $0.count != 1 }
            .bind(to: bubbleView.rx.isHidden)
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
    @IBOutlet weak var tabView: TabBarView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnMainEmotion: UIButton!
    
    @IBOutlet weak var rankingView: UIStackView!
    @IBOutlet weak var lblRanking0: UILabel!
    @IBOutlet weak var lblRanking0Days: UILabel!
    @IBOutlet weak var lblRanking1: UILabel!
    @IBOutlet weak var lblRanking1Days: UILabel!
    @IBOutlet weak var lblRanking2: UILabel!
    @IBOutlet weak var lblRanking3: UILabel!
    
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var colDays: UICollectionView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var imgBubble: UIImageView!
}

// MARK: - UIScrollViewDelegate

extension MonthlyVC: UIScrollViewDelegate {
    /* 스크롤 시 탭바 표시 */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateTabView()
    }
    
    /* 스크롤 중단 시 탭바 숨기기 */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateTabView()
    }
    
    /* 랭킹 3개 이상 등록되면 탭바 고정 */
    func animateTabView() {
        if viewModel.rankings.value.count > 2 {
            if self.scrollView.contentOffset.equalTo(.zero) {
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.tabView.transform = CGAffineTransform(translationX: 0, y: self.tabView.frame.height)
                })
            } else if tabView.transform.ty > 0 {
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.tabView.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
        }
    }
}

extension MonthlyVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
}


