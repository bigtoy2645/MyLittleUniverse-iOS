//
//  MyWordsCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/06.
//

import UIKit
import RxSwift
import RxCocoa

class MyWordsCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    static let identifier = "wordsCell"
    let words = BehaviorRelay<[String]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBinding()
        
        colWords.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
        if let flowLayout = colWords.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    func setupBinding() {
        colWords.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // 감정 리스트
        words
        .bind(to: colWords.rx.items(cellIdentifier: MyWordCell.identifier,
                                          cellType: MyWordCell.self)) { index, word, cell in
            cell.word.accept(word)
            cell.layoutIfNeeded()
        }
        .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var colWords: UICollectionView!
    @IBOutlet weak var viewConsonant: UIView!
    @IBOutlet weak var lblConsonant: UILabel!
    @IBOutlet weak var consonantTop: NSLayoutConstraint!
    @IBOutlet weak var consonantBottom: NSLayoutConstraint!
}

class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumInteritemSpacing = 24.0
        self.minimumLineSpacing = 12.0
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return [] }
        
        for (idx, attr) in attributes.enumerated() {
            if attr.frame.origin.x == 0 { continue }
            
            if idx == 0 {
                attr.frame.origin.x = 0
            } else {
                attr.frame.origin.x = attributes[idx-1].frame.maxX + minimumInteritemSpacing
            }
        }
        return attributes
    }
}
