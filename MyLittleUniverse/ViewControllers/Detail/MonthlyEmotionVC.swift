//
//  MonthlyEmotionVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/02.
//

import UIKit
import RxSwift
import RxCocoa

class MonthlyEmotionVC: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    static let storyboardID = "detailView"
    
    var viewModel = MonthlyEmotionViewModel(date: Date(), emotion: Emotion.empty)
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
        navigationController?.overrideUserInterfaceStyle = .light
    }
    
    /* Binding */
    func setupBindings() {
        btnBack.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.moments
            .bind(to: tableView.rx.items(cellIdentifier: MomentTableViewCell.identifier,
                                         cellType: MomentTableViewCell.self)) {
                _, item, cell in
                cell.moment = ViewMoment(item)
            }
            .disposed(by: disposeBag)
        
        viewModel.emotionString
            .bind(to: lblEmotion.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dateString
            .bind(to: lblDate.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.numOfDayString
            .bind(to: lblCount.rx.text)
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 460
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSorting: UIButton!
    
    @IBOutlet weak var lblEmotion: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCount: UILabel!
}
