//
//  PaintColorChipViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/05.
//

import UIKit
import RxSwift
import RxCocoa

class ColorChipVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    var hexColors = BehaviorRelay<[Int]>(value: [
        0xF03636, 0xFA6103, 0xFFC123, 0xF6E43E, 0x69C852, 0x5DBBFF, 0x2C41AC, 0x6D3289,
        0xF34757, 0xF45039, 0xFA9926, 0xECCD2B, 0x2DAE85, 0x223C2D, 0x294966, 0x3C2347,
        0xFFB8B7, 0xFFD9C3, 0xFFECC7, 0xA3C4DC, 0x7C99FF, 0xD4B9EC, 0x9F88C8, 0x975BE4,
        0xFD9673, 0x905E30, 0x955857, 0x000000, 0x666666, 0xCCCCCC, 0xE6E6E6, 0xFFFFFF
    ])
    
    var selectedColor = BehaviorSubject<Int?>(value: nil)
    var completeHandler: ((Int) -> ())?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colColorChip.dataSource = self
        colColorChip.backgroundColor = .clear
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        colColorChip.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // 컬러칩 선택
        colColorChip.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                if let cell = self.colColorChip.cellForItem(at: index) as? ColorChipCell {
                    self.completeHandler?(cell.hexColor)
                }
            })
            .disposed(by: disposeBag)
        
        // 선택된 컬러칩 변경
        selectedColor
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                if let hexColor = $0,
                   let indexRow = self.hexColors.value.firstIndex(of: hexColor) {
                    self.colColorChip.selectItem(at: IndexPath(row: indexRow, section: 0),
                                                 animated: false,
                                                 scrollPosition: .top)
                } else {
                    self.colColorChip.deselectAll()
                }
            })
            .disposed(by: disposeBag)
    }
    
    /* 셀 크기 */
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 64) / 8.0
        let height = width
        return CGSize(width: width, height: height)
    }
    
    /* 셀 개수 */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hexColors.value.count
    }
    
    /* 셀 그리기 */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorWellCell.identifier, for: indexPath) as! ColorWellCell
            cell.colorWell.addTarget(self, action: #selector(colorWellChanged(_:)), for: .valueChanged)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorChipCell.identifier, for: indexPath) as! ColorChipCell
            cell.hexColor = hexColors.value[indexPath.row]
            return cell
        }
    }
    
    /* ColorWell 색상 변경 */
    @objc func colorWellChanged(_ sender: UIColorWell) {
        DispatchQueue.main.async {
            self.colColorChip.selectItem(at: IndexPath(row: 0, section: 0),
                                            animated: false,
                                            scrollPosition: .left)
            if let selectedColor = sender.selectedColor?.rgb() {
                self.completeHandler?(selectedColor)
            }
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var colColorChip: UICollectionView!
}
