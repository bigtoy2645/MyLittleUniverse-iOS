//
//  CardVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/29.
//

import UIKit
import RxSwift
import RxCocoa

class CardVC: UIViewController {
    let moments = BehaviorRelay<[Moment]>(value: [])
    var height = BehaviorRelay<CGFloat>(value: 300)
    var noneView = UIView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(noneView)
        noneView.translatesAutoresizingMaskIntoConstraints = false
        noneView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        noneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        noneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        let lblDescription = UILabel()
        lblDescription.text = "등록된 감정 카드가 없습니다."
        lblDescription.textColor = .mediumGray
        lblDescription.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        noneView.addSubview(lblDescription)
        lblDescription.translatesAutoresizingMaskIntoConstraints = false
        lblDescription.topAnchor.constraint(equalTo: noneView.topAnchor, constant: 32).isActive = true
        lblDescription.centerXAnchor.constraint(equalTo: noneView.centerXAnchor).isActive = true
    }
    
    /* Binding */
    func setupBindings() {
        colMoments.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        colMoments.rx.willDisplayCell
            .subscribe(onNext: { _ in
                var height = self.colMoments.contentSize.height
                if height <= 0 { height = self.momentsHeight.constant }
                self.momentsHeight.constant = height
                self.height.accept(height)
            })
            .disposed(by: disposeBag)
        
        moments.map { $0.isEmpty ? 128 : self.height.value }
            .bind { self.height.accept($0) }
            .disposed(by: disposeBag)
        
        moments.map { !$0.isEmpty }
            .bind(to: noneView.rx.isHidden)
            .disposed(by: disposeBag)
        
        moments.map { $0.isEmpty }
            .bind(to: colMoments.rx.isHidden)
            .disposed(by: disposeBag)
        
        moments
            .bind(to: colMoments.rx.items(cellIdentifier: DayMomentCell.identifier,
                                          cellType: DayMomentCell.self)) { index, moment, cell in
                cell.moment.accept(moment)
            }
                                          .disposed(by: disposeBag)
    }
    
    @IBOutlet weak var colMoments: UICollectionView!
    @IBOutlet weak var momentsHeight: NSLayoutConstraint!
}

// MARK: - UICollectionView

extension CardVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 75) / 2.0
        let height = width * 4 / 3
        return CGSize(width: width, height: height)
    }
}
