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
    }
    
    func setupBinding() {
        colWords.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // 감정 리스트
        words
        .bind(to: colWords.rx.items(cellIdentifier: MyWordCell.identifier,
                                          cellType: MyWordCell.self)) { index, word, cell in
            cell.lblWord.text = word
        }
        .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    @IBOutlet weak var colWords: UICollectionView!
}
