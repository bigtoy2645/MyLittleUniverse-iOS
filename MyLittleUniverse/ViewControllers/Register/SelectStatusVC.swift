//
//  SelectStatusVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/17.
//

import UIKit
import RxSwift
import RxCocoa

class SelectStatusVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    let allStatus: [Status] = [.positive, .negative, .neutral, .random]
    let timeStamp = BehaviorRelay<Date>(value: Date())
    static var parentView: UIViewController?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        SelectStatusVC.parentView = navigationController?.previousViewController
        
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.isUserInteractionEnabled = true
        timeStamp.accept(Date())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.overrideUserInterfaceStyle = .dark
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    /* Binding */
    func setupBindings() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.of(allStatus)
            .bind(to: collectionView.rx.items(cellIdentifier: StatusCell.identifier,
                                              cellType: StatusCell.self)) { index, status, cell in
                cell.lblStatus.text = status.rawValue
            }
            .disposed(by: disposeBag)
        
        timeStamp.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY. MM. dd. EEE. hh:mm a"
            return formatter.string(from: $0)
        }
        .bind(to: lblDate.rx.text)
        .disposed(by: disposeBag)
         
        // 감정 선택
        collectionView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                self.collectionView.isUserInteractionEnabled = false
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    guard let detailVC = Route.getVC(.selectEmotionsVC) as? SelectEmotionsVC else { return }
                    let status = self.allStatus[index.row]
                    detailVC.status.accept(status)
                    detailVC.timeStamp.accept(self.timeStamp.value)
                    self.navigationController?.pushViewController(detailVC, animated: false)
                    self.collectionView.isUserInteractionEnabled = true
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
