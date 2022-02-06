//
//  PaintComponentViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/05.
//

import UIKit
import RxSwift

enum Sticker {
    case color
    case shape
    case picture
}

class PaintStickerViewController: UIViewController, UICollectionViewDelegate {
    static let identifier = "paintStickerView"
    
    var type: Sticker = .color
    var hexColors = BehaviorSubject<[Int]>(value: [
        0xF03636, 0xFA6103, 0xFFC123, 0xF6E43E, 0x69C852, 0x5DBBFF, 0x2C41AC, 0x6D3289,
        0xF34757, 0xF45039, 0xFA9926, 0xECCD2B, 0x2DAE85, 0x223C2D, 0x294966, 0x3C2347,
        0xFFB8B7, 0xFFD9C3, 0xFFECC7, 0xA3C4DC, 0x7C99FF, 0xD4B9EC, 0x9F88C8, 0x975BE4,
        0xFD9673, 0x905E30, 0x955857, 0x000000, 0x666666, 0xCCCCCC, 0xE6E6E6, 0xFFFFFF
    ])
    var completeHandler: ((UIColor) -> ())?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        colSticker.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        hexColors
            .bind(to: colSticker.rx.items(cellIdentifier: PaintColorChipCollectionViewCell.identifier,
                                                 cellType: PaintColorChipCollectionViewCell.self)) { index, hexValue, cell in
                cell.imgCircle.tintColor = UIColor(rgb: hexValue)
            }
            .disposed(by: disposeBag)
        
        colSticker.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                if let cell = self.colSticker.cellForItem(at: index) as? PaintColorChipCollectionViewCell {
                    self.completeHandler?(cell.imgCircle.tintColor)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var colSticker: UICollectionView!
}
