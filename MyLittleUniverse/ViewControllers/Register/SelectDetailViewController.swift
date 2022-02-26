//
//  SelectDetailViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/20.
//

import UIKit
import RxSwift
import RxCocoa

class SelectDetailViewController: UIViewController,
                                  UICollectionViewDelegateFlowLayout, UICollectionViewDelegate,
                                  UIGestureRecognizerDelegate {
    static let storyboardID = "selectDetailView"
    
    let emotionObservable = Observable.of([Emotion.glad, Emotion.exciting, Emotion.touching,
                                           Emotion.satisfied, Emotion.joyful, Emotion.pitapat,
                                           Emotion.comfortable, Emotion.forward, Emotion.belazy,
                                           Emotion.lovely, Emotion.proud, Emotion.happy,
                                           Emotion.relaxed, Emotion.funny, Emotion.confident])
    let selectedEmotions = BehaviorRelay<[Emotion]>(value: [])
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        btnDone.layer.borderWidth = 1
        btnDone.layer.borderColor = UIColor.bgGreen?.cgColor
        btnDone.layer.cornerRadius = 5
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // 감정 리스트
        emotionObservable
            .bind(to: collectionView.rx.items(cellIdentifier: EmotionDetailCollectionViewCell.identifier,
                                              cellType: EmotionDetailCollectionViewCell.self)) { index, status, cell in
                cell.lblStatus.text = status.rawValue
            }
            .disposed(by: disposeBag)
        
        // 감정 선택
        collectionView.rx.modelSelected(Emotion.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { model in
                let emotions = self.selectedEmotions.value + [model]
                self.selectedEmotions.accept(emotions)
            })
            .disposed(by: disposeBag)
        
        // 감정 선택 해제
        collectionView.rx.modelDeselected(Emotion.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { model in
                let emotions = self.selectedEmotions.value.filter { $0 != model }
                self.selectedEmotions.accept(emotions)
            })
            .disposed(by: disposeBag)
        
        // 감정 선택 시에만 버튼 활성화
        selectedEmotions.asObservable()
            .map { $0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isEmpty in
                self.btnDone.isEnabled = !isEmpty
                self.btnDone.backgroundColor = isEmpty ? .pointYellow : .bgGreen
                self.btnDone.setTitleColor(isEmpty ? .black.withAlphaComponent(0.2) : .pointPurple,
                                           for: .normal)
            })
            .disposed(by: disposeBag)
        
        // 선택 완료
        btnDone.rx.tap
            .bind {
                guard let paintListVC = self.storyboard?.instantiateViewController(withIdentifier: PaintListViewController.storyboardID) as? PaintListViewController else { return }
                // 선택한 Emotion 전달
                paintListVC.emotions.onNext(self.selectedEmotions.value)
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
        let width = self.collectionView.frame.width / 3.0
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - InterfaceBuilder Links

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDone: UIButton!
}
