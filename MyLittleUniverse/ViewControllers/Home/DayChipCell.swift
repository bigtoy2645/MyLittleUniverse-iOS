//
//  DayCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit
import RxSwift
import RxCocoa

class DayChipCell: UICollectionViewCell {
    static let identifier = "dayChipCell"
    
    let isRecorded = BehaviorRelay<Bool>(value: false)
    private var disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.width / 2
        
        isRecorded
            .map { isRecorded in
                if isRecorded {
                    return self.isSelected ? .white : .mainBlack
                } else {
                    return UIColor.disableGray
                }
            }
            .bind(to: lblDay.rx.textColor)
            .disposed(by: disposeBag)
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .bgGreen : .clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblDay: UILabel!
}
