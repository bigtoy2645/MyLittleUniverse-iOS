//
//  DetailViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/02.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    static let storyboardID = "detailView"
    
    let moments = BehaviorSubject<[ViewMoment]>(value: [])
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: MomentTableViewCell.nibName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: MomentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    /* Binding */
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
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 460
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
}
