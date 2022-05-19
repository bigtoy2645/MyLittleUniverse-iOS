//
//  MomentTableViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import UIKit
import RxSwift

class MomentTableViewCell: UITableViewCell {
    static let nibName = "MomentTableViewCell"
    static let identifier = "momentCell"
    
    var moment = BehaviorSubject<Moment>(value: Moment.empty)
    let textColor = BehaviorSubject<UIColor>(value: UIColor.black)
    private var disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 30, bottom: 15, right: 30))
        contentView.layer.cornerRadius = 10
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        moment.map { UIColor(rgb: $0.bgColor) }
            .bind(to: contentView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        moment.map { UIImage(data: $0.imageData) }
            .bind(to: imageCard.rx.image)
            .disposed(by: disposeBag)
        
        moment.map { $0.text.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: descriptionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        moment.map { $0.text }
            .bind(to: lblDescription.rx.text)
            .disposed(by: disposeBag)
        
        moment.map { "\($0.year).\($0.month).\($0.day)" }
            .bind(to: lblDate.rx.text)
            .disposed(by: disposeBag)
        
        moment.map { $0.emotion.word }
            .bind(to: lblEmotion.rx.text)
            .disposed(by: disposeBag)
        
        // Color
        moment.map { UIColor(rgb: $0.textColor) }
            .subscribe(onNext: textColor.onNext(_:))
            .disposed(by: disposeBag)
        
        textColor
            .bind(to: btnKebab.rx.tintColor)
            .disposed(by: disposeBag)
        
        textColor
            .bind(to: lblDate.rx.textColor)
            .disposed(by: disposeBag)
        
        textColor
            .bind(to: lblSeperator.rx.textColor)
            .disposed(by: disposeBag)
        
        textColor
            .bind(to: lblEmotion.rx.textColor)
            .disposed(by: disposeBag)
        
        textColor
            .bind(to: lblDescription.rx.textColor)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSeperator: UILabel!
    @IBOutlet weak var lblEmotion: UILabel!
    
    @IBOutlet weak var imageCard: UIImageView!
    @IBOutlet weak var btnKebab: UIButton!
}
