//
//  MyWordCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/06.
//

import UIKit
import RxSwift
import RxCocoa

class MyWordCell: UICollectionViewCell {
    static let identifier = "wordCell"
    
    var word = BehaviorRelay<String>(value: "")
    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        word.bind(to: lblWord.rx.text)
            .disposed(by: disposeBag)
    }
    
    @IBOutlet weak var lblWord: UILabel!
}
