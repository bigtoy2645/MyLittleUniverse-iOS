//
//  DayMomentCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/19.
//

import UIKit
import RxSwift
import RxCocoa

class DayMomentCell: UICollectionViewCell {
    static let identifier = "dayMomentCell"
    
    var moment = BehaviorRelay<Moment>(value: Moment.empty)
    private var disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        addShadow(offset: CGSize(width: 0, height: 5), color: .disableGray, opacity: 0.5, radius: 6)
        contentView.layer.cornerRadius = 8
        
        moment.map { $0.emotion.word }
            .bind(to: lblStatus.rx.text)
            .disposed(by: disposeBag)
        
        moment.map { UIColor(rgb: $0.textColor) }
            .bind(to: lblStatus.rx.textColor)
            .disposed(by: disposeBag)
        
        moment.map { UIImage(data: $0.imageData) }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        moment.map { UIColor(rgb: $0.bgColor) }
            .bind(to: contentView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        contentView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                guard let detailVC = Route.getVC(.cardDetailVC) as? CardDetailVC,
                      let currentVC = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController else { return }
                detailVC.moment.accept(self.moment.value)
                detailVC.imageSavedHandler = {
                    DispatchQueue.main.async {
                        Dialog.presentImageSaved(detailVC)
                    }
                }
                detailVC.removeHandler = { moment in
                    DispatchQueue.main.async {
                        Dialog.presentRemove(detailVC, moment: moment) {
                            detailVC.dismiss(animated: false)
                        }
                    }
                }
                detailVC.modalPresentationStyle = .overFullScreen
                currentVC.present(detailVC, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
}
