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
    var viewModel = MonthlyEmotionViewModel(emotion: Emotion.empty)
    private let disposeBag = DisposeBag()
    
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
        
        sortingView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                let isLatest = self.viewModel.isLatest.value
                self.viewModel.isLatest.accept(!isLatest)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLatest
            .map { $0 ? "최신순" : "등록일순" }
            .bind(to: lblSorting.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.moments
            .bind(to: tableView.rx.items(cellIdentifier: MomentTableViewCell.identifier,
                                         cellType: MomentTableViewCell.self)
            ) { _, item, cell in
                cell.moment.onNext(item)
                cell.layoutIfNeeded()
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
        return UITableView.automaticDimension
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var sortingView: UIStackView!
    @IBOutlet weak var lblSorting: UILabel!
    
    @IBOutlet weak var lblEmotion: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCount: UILabel!
}
