//
//  DetailViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/02.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    static let storyboardID = "detailView"
    
    let moments = BehaviorSubject<[Moment]>(value: [])
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    func setupBindings() {
        // 테이블뷰 아이템
        moments
            .bind(to: tableView.rx.items(cellIdentifier: MomentTableViewCell.identifier,
                                         cellType: MomentTableViewCell.self)) {
                _, item, cell in
                cell.onData.onNext(item)
            }
            .disposed(by: disposeBag)
        
        btnBack.rx.tap
            .bind {
                self.dismiss(animated: false, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!
}
