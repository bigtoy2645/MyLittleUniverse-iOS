//
//  TodayViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/17.
//

import UIKit
import RxSwift

class TodayViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    static let storyboardID = "todayView"
    
    let statusObservable = Observable.of(["좋아요", "좋지 않아요", "그저 그래요", "복합적인 것 같아요"])
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일"
        lblDate.text = formatter.string(from: Date())
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        statusObservable
            .bind(to: collectionView.rx.items(cellIdentifier: TodayCollectionViewCell.identifier,
                                              cellType: TodayCollectionViewCell.self)) { index, status, cell in
                cell.lblStatus.text = status
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.white.cgColor
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { index in
                print("\(index.section) \(index.row)")
            })
            .disposed(by: disposeBag)
        
        // 닫기 버튼
        btnClose.rx.tap
            .bind {
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width / 2.0
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnClose: UIButton!
}
