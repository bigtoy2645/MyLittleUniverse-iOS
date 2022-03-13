//
//  PaintStickerViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/19.
//

import UIKit
import RxSwift

enum StickerShapeType {
    case lineShape
    case fillShape
}

class ShapeStickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    static let identifier = "paintShapeStickerView"
    
    var completeHandler: ((UIImage?) -> ())?
    var disposeBag = DisposeBag()
    var type = BehaviorSubject<StickerShapeType>(value: .lineShape)
    var stickers = BehaviorSubject<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        type.subscribe(onNext: { type in
            switch type {
            case .lineShape:
                self.stickers.onNext(["line_shape/Polygon", "line_shape/Ellipse 28", "line_shape/Rectangle 143",
                                      "line_shape/Rectangle 144", "line_shape/Rectangle 41-1", "line_shape/Rectangle 41",
                                      "line_shape/Ellipse 28-1", "line_shape/Ellipse 37", "line_shape/Vector 9",
                                      "line_shape/Star", "line_shape/Union","line_shape/Heart", "line_shape/Rectangle 145",
                                      "line_shape/Ellipse 216", "line_shape/Ellipse 216-1", "line_shape/Water"])
            case .fillShape:
                self.stickers.onNext(["fill_shape/Polygon", "fill_shape/Ellipse 28", "fill_shape/Rectangle 143",
                                      "fill_shape/Rectangle 144", "fill_shape/Rectangle 41-1", "fill_shape/Rectangle 41",
                                      "fill_shape/Ellipse 28-1", "fill_shape/Ellipse 37", "fill_shape/Vector 9",
                                      "fill_shape/Star", "fill_shape/Union", "fill_shape/Heart", "fill_shape/Rectangle 145",
                                      "fill_shape/Ellipse 216", "fill_shape/Ellipse 216-1", "fill_shape/Water"])
            }
        })
        .disposed(by: disposeBag)
        
        colSticker.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        stickers
            .bind(to: colSticker.rx.items(cellIdentifier: ShapeStickerCell.identifier,
                                          cellType: ShapeStickerCell.self)) { index, imgName, cell in
                cell.sticker.image = UIImage(named: imgName)
        }
        .disposed(by: disposeBag)
        
        colSticker.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                if let cell = self.colSticker.cellForItem(at: index) as? ShapeStickerCell {
                    self.completeHandler?(cell.sticker.image)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.colSticker.frame.width / 4.0 - 8
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var colSticker: UICollectionView!
}
