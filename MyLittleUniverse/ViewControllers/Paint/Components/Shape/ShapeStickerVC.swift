//
//  ShapeStickerVC.swift
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
    var type = BehaviorSubject<StickerShapeType>(value: .lineShape)
    var stickers = BehaviorSubject<[String]>(value: [])
    var completeHandler: ((UIImage?) -> ())?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        type.subscribe(onNext: { type in
            switch type {
            case .lineShape:
                self.stickers.onNext(["line_shape/Triangle", "line_shape/Circle", "line_shape/Rectangle",
                                      "line_shape/Oblong", "line_shape/Arch", "line_shape/Scround",
                                      "line_shape/Half-circle", "line_shape/Quarter-circle", "line_shape/Sparkle",
                                      "line_shape/Star", "line_shape/Flower","line_shape/Heart", "line_shape/Diamond",
                                      "line_shape/Ellipse", "line_shape/Cone", "line_shape/Waterdrop"])
            case .fillShape:
                self.stickers.onNext(["fill_shape/Triangle", "fill_shape/Circle", "fill_shape/Rectangle",
                                      "fill_shape/Oblong", "fill_shape/Arch", "fill_shape/Scround",
                                      "fill_shape/Half-circle", "fill_shape/Quarter-circle", "fill_shape/Sparkle",
                                      "fill_shape/Star", "fill_shape/Flower","fill_shape/Heart", "fill_shape/Diamond",
                                      "fill_shape/Ellipse", "fill_shape/Cone", "fill_shape/Waterdrop"])
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
