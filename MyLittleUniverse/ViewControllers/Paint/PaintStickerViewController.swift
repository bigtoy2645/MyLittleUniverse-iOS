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
    case image
}

class PaintStickerViewController: UIViewController, UICollectionViewDelegate {
    static let identifier = "paintStickerView"
    
    var type: Sticker = .color
    var colors = BehaviorSubject<[UIColor]>(value: [.systemPink, .blue, .blue, .brown, .darkGray,
                                                    .green, .orange, .red, .systemTeal, .systemPink,
                                                    .blue, .blue, .brown, .systemPink, .blue, .blue, .brown, .darkGray,
                                                    .green, .orange, .red, .systemTeal, .systemPink,
                                                    .blue, .blue, .brown, .systemPink, .blue, .blue, .brown, .darkGray,
                                                    .green, .orange, .red, .systemTeal, .systemPink,
                                                    .blue, .blue, .brown, .systemPink, .blue, .blue, .brown, .darkGray,
                                                    .green, .orange, .red, .systemTeal, .systemPink,
                                                    .blue, .blue, .brown])
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
        
        colors
            .bind(to: colSticker.rx.items(cellIdentifier: PaintColorChipCollectionViewCell.identifier,
                                                 cellType: PaintColorChipCollectionViewCell.self)) { index, color, cell in
                cell.imgCircle.tintColor = color
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
