//
//  MyUniverseVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/22.
//

import UIKit
import RxSwift
import RxCocoa

class MyUniverseVC: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate {
    let words = BehaviorRelay<[String]>(value: [])
    let moments = BehaviorRelay<[[String]]>(value: [])
    let consonantList = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // Cell 등록
        tblWords.rowHeight = UITableView.automaticDimension
        tblWords.delegate = self
        
        setupBindings()
        
        // 감정 단어 불러오기
        Repository.instance.wordList { words in
            self.words.accept(words)
            self.indicator.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    /* Binding */
    func setupBindings() {
        btnBack.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        words
            .map {
                var setWords = Set<String>()
                var section = Array(repeating: [String](), count: self.consonantList.count)
                
                $0.forEach { setWords.insert($0) }
                for word in setWords {
                    let index = self.getConsonantIndex(word)
                    section[index].append(word)
                }
                
                return section.map { $0.sorted(by: <) }.filter { $0.count > 0 }
            }
            .bind(to: moments)
            .disposed(by: disposeBag)
        
        moments
            .bind(to: tblWords.rx.items(cellIdentifier: MyWordsCell.identifier,
                                        cellType: MyWordsCell.self)
            ) { index, item, cell in
                let words = item
                cell.words.accept(words)
                cell.lblConsonant.text = self.consonantList[self.getConsonantIndex(words[0])]
                if index == 0 {
                    cell.consonantTop.constant = 24
                    cell.viewConsonant.clipsToBounds = true
                    cell.viewConsonant.layer.cornerRadius = 13
                    cell.viewConsonant.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                } else if index == self.moments.value.count - 1 {
                    cell.consonantBottom.constant = 24
                    cell.viewConsonant.clipsToBounds = true
                    cell.viewConsonant.layer.cornerRadius = 13
                    cell.viewConsonant.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                }
                cell.layoutIfNeeded()
                cell.collectionHeight.constant = cell.colWords.collectionViewLayout.collectionViewContentSize.height
            }
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /* 자음 인덱스 */
    func getConsonantIndex(_ word: String) -> Int {
        let octal = word.unicodeScalars[word.unicodeScalars.startIndex].value
        var index = (octal - 0xac00) / 28 / 21
        // 쌍자음
        if index == 1 || index == 4 || index == 8 || index == 10 || index == 13 {
            index -= 1
        }
        return Int(index)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var tblWords: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
}
