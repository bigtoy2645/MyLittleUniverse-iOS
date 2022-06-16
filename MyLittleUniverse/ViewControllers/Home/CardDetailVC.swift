//
//  CardDetailVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/15.
//

import UIKit
import RxSwift
import RxCocoa

class CardDetailVC: UIViewController {
    var moment = BehaviorRelay<Moment>(value: Moment.empty)
    let textColor = BehaviorSubject<UIColor>(value: UIColor.black)
    var imageSavedHandler: (() -> Void)?
    var removeHandler: ((Moment) -> Void)?
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dialogView.layer.cornerRadius = 4
    }
    
    /* Binding */
    func setupBindings() {
        moment.map { UIColor(rgb: $0.bgColor) }
            .bind(to: cardView.rx.backgroundColor)
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
        
        moment.map {
            let formatter = DateFormatter()
            let date = Date(timeIntervalSinceReferenceDate: $0.timeStamp)
            formatter.dateFormat = "YYYY.MM.dd"
            return formatter.string(from: date)
        }
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
        
        btnSave.rx.tap
            .bind { self.saveImage() }
            .disposed(by: disposeBag)
        
        btnRemove.rx.tap
            .bind {
                self.removeHandler?(self.moment.value)
            }
            .disposed(by: disposeBag)
        
        btnClose.rx.tap
            .bind {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    /* 이미지 저장 */
    func saveImage() {
        UIImageWriteToSavedPhotosAlbum(cardView.asImage(),
                                       self,
                                       #selector(imageSaved(image:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    /* 이미지 저장 후 */
    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: Error, contextInfo: UnsafeMutableRawPointer?) {
        imageSavedHandler?()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var cardView: UIStackView!
    @IBOutlet weak var imageCard: UIImageView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSeperator: UILabel!
    @IBOutlet weak var lblEmotion: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
}
