//
//  PaintStickerViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/19.
//

import UIKit
import RxSwift

enum Sticker {
    case lineShape
    case fillShape
    case picture
}

class PaintStickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    static let identifier = "paintStickerView"
    
    var completeHandler: ((UIImage?) -> ())?
    var disposeBag = DisposeBag()
    var type = BehaviorSubject<Sticker>(value: .lineShape)
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
            case .lineShape:
                self.stickers.onNext(["Polygon1", "Ellipse28", "Ellipse37", "Ellipse68"])
            case .fillShape:
                self.stickers.onNext(["fill_shape/Ellipse 28-1", "fill_shape/Ellipse 28"])
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
                cell.tintColor = UIColor(rgb: 0xC4C4C4)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.colSticker.frame.width / 4.0
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var colSticker: UICollectionView!
}
