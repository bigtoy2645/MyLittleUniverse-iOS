//
//  ClippingPictureStickerVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/04/01.
//

import UIKit
import RxSwift

class ClippingPictureStickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var originImage = BehaviorSubject<UIImage?>(value: nil)
    var completeHandler: ((UIImage?) -> ())?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        colSticker.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        originImage.map { image -> [UIImage?] in
            if let image = image {
                return [self.triangle(image), self.circle(image), image, self.oblong(image),
                        self.arch(image), self.scround(image), self.halfCircle(image), self.quarterCircle(image)]
            }
            return []
        }
        .bind(to: colSticker.rx.items(cellIdentifier: PictureStickerCell.identifier,
                                      cellType: PictureStickerCell.self)) { index, image, cell in
            cell.sticker.image = image
        }
        .disposed(by: disposeBag)
        
        colSticker.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { index in
                if let cell = self.colSticker.cellForItem(at: index) as? PictureStickerCell {
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

// MARK: - Clipping Shape

extension ClippingPictureStickerVC {
    private func triangle(_ image: UIImage) -> UIImage? {
        let size = image.size
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.close()
        
        return image.clip(path: path)
    }
    
    private func circle(_ image: UIImage) -> UIImage? {
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: image.size))
        
        return image.clip(path: path)
    }
    
    private func oblong(_ image: UIImage) -> UIImage? {
        let size = image.size
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: size.height / 4))
        path.addLine(to: CGPoint(x: 0, y: size.height / 4 * 3))
        path.addLine(to: CGPoint(x: size.width, y: size.height / 4 * 3))
        path.addLine(to: CGPoint(x: size.width, y: size.height / 4))
        path.close()
        
        return image.clip(path: path)
    }
    
    private func arch(_ image: UIImage) -> UIImage? {
        let size = image.size
        let path = UIBezierPath(roundedRect: CGRect(x: size.width / 5,
                                                    y: 0,
                                                    width: size.width / 5 * 3,
                                                    height: size.height),
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: size)
        
        return image.clip(path: path)
    }
    
    private func scround(_ image: UIImage) -> UIImage? {
        let size = image.size
        let path = UIBezierPath(roundedRect: CGRect(x: size.width / 5,
                                                    y: 0,
                                                    width: size.width / 5 * 3,
                                                    height: size.height),
                                byRoundingCorners: .allCorners,
                                cornerRadii: size)
        
        return image.clip(path: path)
    }
    
    private func halfCircle(_ image: UIImage) -> UIImage? {
        let size = image.size
        let path = UIBezierPath(arcCenter: CGPoint(x: size.width / 2, y: size.height / 4 * 3),
                                radius: size.width / 2,
                                startAngle: 0,
                                endAngle: .pi,
                                clockwise: false)
        
        return image.clip(path: path)
    }
    
    func quarterCircle(_ image: UIImage) -> UIImage? {
        let size = image.size
        let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: size.height),
                                radius: size.width,
                                startAngle: 0,
                                endAngle: .pi / 2,
                                clockwise: false)
        
        return image.clip(path: path)
    }
}
