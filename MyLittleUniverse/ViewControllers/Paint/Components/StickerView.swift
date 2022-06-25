//
//  StickerView.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/25.
//

import UIKit
import RxSwift
import RxCocoa

struct StickerView {
    let sticker = BehaviorRelay<Sticker>(value: Sticker(type: .shape))
    var view = UIView()
    private let disposeBag = DisposeBag()
    
    init(sticker: Sticker, view: UIView) {
        self.sticker.accept(sticker)
        self.view = view
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        // 이미지 스티커
        sticker.asObservable()
            .map { ($0.image, $0.hexColor) }
            .observe(on: MainScheduler.instance)
            .bind { image, hexColor in
                guard let image = image else { return }
                if let imageView = self.view as? UIImageView {
                    imageView.image = image
                    imageView.tintColor = UIColor(rgb: hexColor)
                }
//                else {
//                    let imageView = UIImageView()
//                    imageView.clipsToBounds = true
//                    imageView.tintColor = UIColor(rgb: hexColor)
//                    imageView.image = image
//                    imageView.contentMode = .scaleAspectFit
//                    view = imageView
//                }
            }
            .disposed(by: disposeBag)

        // 텍스트 스티커
        sticker.asObservable()
            .map { ($0.text, $0.hexColor) }
            .observe(on: MainScheduler.instance)
            .bind { text, hexColor in
                guard let text = text else { return }
                if let labelView = self.view as? UILabel {
                    labelView.text = text
                    labelView.textColor = UIColor(rgb: hexColor)
                    labelView.sizeToFit()
                }
//                else {
//                    let lblText = UILabel()
//                    lblText.text = text
//                    lblText.textColor = .black
//                    lblText.textAlignment = .center
//                    lblText.lineBreakMode = .byClipping
//                    self.view = lblText
//                }
            }
            .disposed(by: disposeBag)
    }
}

extension StickerView: Equatable {
    static func == (lhs: StickerView, rhs: StickerView) -> Bool {
        return (lhs.sticker.value == rhs.sticker.value &&
                lhs.view == rhs.view)
    }
}
