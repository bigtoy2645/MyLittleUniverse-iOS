//
//  PaintStickerViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/19.
//

import UIKit
import RxSwift

enum Sticker {
    case shape
    case fillShape
    case picture
}

class PaintStickerViewController: UIViewController, UICollectionViewDelegate {
    static let identifier = "paintStickerView"
    
    var completeHandler: ((UIImage?) -> ())?
    var disposeBag = DisposeBag()
    var type = BehaviorSubject<Sticker>(value: .shape)
    var stickers = BehaviorSubject<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        type.subscribe(onNext: { type in
            switch type {
            case .picture:
                self.stickers.onNext([])
            case .shape:
                self.stickers.onNext(["Polygon1", "Ellipse28", "Ellipse37", "Ellipse68"])
            case .fillShape:
                self.stickers.onNext([])
            }
        })
        .disposed(by: disposeBag)
        
        colSticker.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        stickers
            .bind(to: colSticker.rx.items(cellIdentifier: PaintStickerCollectionViewCell.identifier,
                                          cellType: PaintStickerCollectionViewCell.self)) { index, imgName, cell in
                cell.sticker.image = UIImage(named: imgName)
        }
        .disposed(by: disposeBag)
        
        colSticker.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                if let cell = self.colSticker.cellForItem(at: index) as? PaintStickerCollectionViewCell {
                    self.completeHandler?(cell.sticker.image)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var colSticker: UICollectionView!
}
