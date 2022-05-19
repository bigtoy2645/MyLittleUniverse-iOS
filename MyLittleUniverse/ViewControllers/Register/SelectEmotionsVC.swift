//
//  SelectEmotionsVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/20.
//

import UIKit
import RxSwift
import RxCocoa

class SelectEmotionsVC: UIViewController,
                                  UICollectionViewDelegateFlowLayout, UICollectionViewDelegate,
                                  UIGestureRecognizerDelegate {    
    let status = BehaviorRelay<Status>(value: .positive)
    let selectedEmotions = BehaviorRelay<[Emotion]>(value: [])
    let selectedEmotionCount = BehaviorRelay<Int>(value: 0)
    let timeStamp = BehaviorRelay<Date>(value: Date())
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colEmotions.allowsMultipleSelection = true
        btnDone.layer.cornerRadius = 4
        viewCount.layer.cornerRadius = 10
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .light
    }
    
    /* Binding */
    func setupBindings() {
        colEmotions.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // 상태
        status.map { $0.rawValue }
            .bind(to: lblStatus.rx.text)
            .disposed(by: disposeBag)
        
        // 감정 리스트
        status.map { $0.emotions() }
        .bind(to: colEmotions.rx.items(cellIdentifier: emotionCell.identifier,
                                          cellType: emotionCell.self)) { index, emotion, cell in
            cell.lblStatus.text = emotion.word
        }
        .disposed(by: disposeBag)
        
        // 감정 선택
        colEmotions.rx.modelSelected(Emotion.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { model in
                let emotions = self.selectedEmotions.value + [model]
                self.selectedEmotions.accept(emotions)
            })
            .disposed(by: disposeBag)
        
        // 감정 선택 해제
        colEmotions.rx.modelDeselected(Emotion.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { model in
                let emotions = self.selectedEmotions.value.filter { $0 != model }
                self.selectedEmotions.accept(emotions)
            })
            .disposed(by: disposeBag)
        
        // 선택한 감정 개수
        selectedEmotions.asObservable()
            .map { $0.count }
            .subscribe(onNext: selectedEmotionCount.accept(_:))
            .disposed(by: disposeBag)
        
        // 다 찾았어요 버튼 활성화
        selectedEmotionCount.map { $0 > 0 }
            .bind(to: btnDone.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 다 찾았어요 버튼 색상
        selectedEmotionCount
            .map { $0 > 0 ? .bgGreen : UIColor(rgb: 0xBDC5C0) }
            .bind(to: btnDone.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // 다 찾았어요 라벨 색상
        selectedEmotionCount
            .map { $0 > 0 ? .pointPurple : .white }
            .bind(to: lblDone.rx.textColor)
            .disposed(by: disposeBag)
        
        // 선택한 감정 개수 표시
        selectedEmotionCount.map { $0 <= 0 }
            .bind(to: viewCount.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 선택한 감정 개수
        selectedEmotionCount.map { "\($0)개" }
            .bind(to: lblCount.rx.text)
            .disposed(by: disposeBag)
        
        // 선택 완료
        btnDone.rx.tap
            .bind {
                guard let paintListVC = Route.getVC(.paintEmotionListVC) as? PaintEmotionListVC else { return }
                // 선택한 Emotion 전달
                paintListVC.timeStamp.accept(self.timeStamp.value)
                paintListVC.emotions.accept(self.selectedEmotions.value)
                self.navigationController?.pushViewController(paintListVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // 뒤로 가기
        btnBack.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (colEmotions.frame.width - 16) / 3.0
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var colEmotions: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblDone: UILabel!
}
