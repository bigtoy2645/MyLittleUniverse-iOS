//
//  MyWordsCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/06.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 24
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 8.0
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}

class MyWordsCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    static let identifier = "wordsCell"
    let words = BehaviorRelay<[String]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBinding()
        
//        colWords.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
//        if let flowLayout = colWords.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var colWords: UICollectionView!
    @IBOutlet weak var viewConsonant: UIView!
    @IBOutlet weak var lblConsonant: UILabel!
    @IBOutlet weak var consonantTop: NSLayoutConstraint!
    @IBOutlet weak var consonantBottom: NSLayoutConstraint!
}
