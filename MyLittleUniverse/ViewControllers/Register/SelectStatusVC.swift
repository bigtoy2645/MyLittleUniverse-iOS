//
//  SelectStatusVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/17.
//

import UIKit
import RxSwift

class SelectStatusVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    static let storyboardID = "selectStatusView"
    
    let statusObservable = Observable.of(["좋아요", "좋지 않아요", "둘 다 아니에요", "복합적이에요"])
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일"
        lblDate.text = formatter.string(from: Date())
        
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
    }
    
    /* Binding */
    func setupBindings() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        statusObservable
            .bind(to: collectionView.rx.items(cellIdentifier: StatusCell.identifier,
                                              cellType: StatusCell.self)) { index, status, cell in
                cell.lblStatus.text = status
            }
            .disposed(by: disposeBag)
        
        // 감정 선택
        collectionView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: SelectEmotionsVC.storyboardID) as? SelectEmotionsVC else { return }
                    self.navigationController?.pushViewController(detailVC, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        // 닫기 버튼
        btnClose.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: false)
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
