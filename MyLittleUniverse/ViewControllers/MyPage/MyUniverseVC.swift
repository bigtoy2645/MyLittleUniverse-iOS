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
    let moments = BehaviorRelay<[[String]]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // Cell 등록
        tblWords.rowHeight = UITableView.automaticDimension
        tblWords.delegate = self
        
        setupBindings()
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
        
        Repository.instance.moments
            .map {
                var setWords = Set<String>()
                $0.forEach { setWords.insert($0.emotion.word) }
                return [Array(setWords)]
            }
            .bind(to: moments)
            .disposed(by: disposeBag)
        
        moments
            .bind(to: tblWords.rx.items(cellIdentifier: MyWordsCell.identifier,
                                        cellType: MyWordsCell.self)
            ) { _, item, cell in
                let words = item
                cell.words.accept(words)
                cell.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var tblWords: UITableView!
    @IBOutlet weak var btnBack: UIButton!
}
