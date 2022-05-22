//
//  MomentTableViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown

class MomentTableViewCell: UITableViewCell {
    static let nibName = "MomentTableViewCell"
    static let identifier = "momentCell"
    
    var moment = BehaviorRelay<Moment>(value: Moment.empty)
    let textColor = BehaviorSubject<UIColor>(value: UIColor.black)
    var imageSavedHandler: (() -> Void)?
    var removeHandler: ((Moment) -> Void)?
    private let dropDown = DropDown()
    private var disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 10
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 30, bottom: 15, right: 30))
        
        setupDropDown()
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
        
        btnKebab.rx.tap
            .bind { self.dropDown.show() }
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
    
    /* DropDown 설정 */
    func setupDropDown() {
        dropDown.dataSource = ["저장", "삭제"]
        dropDown.layer.cornerRadius = 8
        dropDown.width = 57
        dropDown.cellHeight = 40
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            cell.optionLabel.textAlignment = .center
        }
        dropDown.textFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        dropDown.anchorView = btnKebab
        if let anchorView = dropDown.anchorView?.plainView {
            dropDown.bottomOffset = CGPoint(x: -(57 - anchorView.bounds.width),
                                            y: (anchorView.bounds.height) / 2)
        }
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                btnKebab.isHidden = true
                UIImageWriteToSavedPhotosAlbum(contentView.asImage(),
                                               self,
                                               #selector(imageSaved(image:didFinishSavingWithError:contextInfo:)),
                                               nil)
            } else {
                removeHandler?(moment.value)
            }
            self.dropDown.clearSelection()
        }
        
        DropDown.appearance().textColor = .mainBlack
        DropDown.appearance().selectedTextColor = .mainBlack
        DropDown.appearance().backgroundColor = .white
        DropDown.appearance().selectionBackgroundColor = .disableGray
        DropDown.appearance().setupCornerRadius(8)
        dropDown.dismissMode = .automatic
    }
    
    /* 이미지 저장 */
    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: Error, contextInfo: UnsafeMutableRawPointer?) {
        btnKebab.isHidden = false
        imageSavedHandler?()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var cardView: UIStackView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSeperator: UILabel!
    @IBOutlet weak var lblEmotion: UILabel!
    
    @IBOutlet weak var imageCard: UIImageView!
    @IBOutlet weak var btnKebab: UIButton!
}
