//
//  PaintPictureStickerViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit
import RxSwift

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

class PictureStickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    static let identifier = "paintPictureStickerView"
    
    var completeHandler: ((UIImage?) -> ())?
    var disposeBag = DisposeBag()
    var stickers = BehaviorSubject<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        self.stickers.onNext([
            "https://images.unsplash.com/photo-1621886671500-66a77b03e75d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NTF8fHBpY25pY3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60",
            "https://images.unsplash.com/photo-1596662501811-39a677aa60e5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1063&q=80",
            "https://images.unsplash.com/photo-1514897575457-c4db467cf78e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80",
            "https://images.unsplash.com/photo-1512911268383-f74e84ff8496?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80",
            "https://images.unsplash.com/photo-1600172454132-ada7faa101cf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1035&q=80",
            "https://images.unsplash.com/photo-1536514498073-50e69d39c6cf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2071&q=80",
            "https://images.unsplash.com/photo-1489549132488-d00b7eee80f1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80",
            "https://images.unsplash.com/photo-1624759314989-1d1ae62a6980?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzV8fHBpY25pY3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60",
            "https://images.unsplash.com/photo-1513553404607-988bf2703777?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1036&q=80",
            "https://images.unsplash.com/photo-1632341503970-dbec32e7ec76?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxjb2xsZWN0aW9uLXBhZ2V8Mjl8MzgyMDEyNzJ8fGVufDB8fHx8&auto=format&fit=crop&w=800&q=60",
            "https://images.unsplash.com/photo-1525838983331-f8bd3c000585?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80",
            "https://images.unsplash.com/photo-1506545632994-973468d2bb18?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nzl8fHBpY25pY3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60"
        ])
        
        colSticker.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        stickers
            .bind(to: colSticker.rx.items(cellIdentifier: PictureStickerCell.identifier,
                                          cellType: PictureStickerCell.self)) { index, urlString, cell in
                if let cachedImage = ImageCacheManager.shared.object(forKey: NSString(string: urlString)) {
                    cell.sticker.image = cachedImage
                } else {
                    UIImage.download(from: urlString, completion: { image in
                        cell.sticker.image = image
                    })
                }
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
