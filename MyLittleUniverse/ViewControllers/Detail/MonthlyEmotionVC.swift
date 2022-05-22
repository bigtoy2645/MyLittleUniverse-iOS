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
                cell.moment.accept(item)
                cell.layoutIfNeeded()
                cell.imageSavedHandler = { self.presentImageSavedAlert() }
                cell.removeHandler = { moment in self.presentRemoveAlert(moment: moment) }
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
    
    /* 사진 저장 알림 */
    func presentImageSavedAlert() {
        guard let alertToast = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertToast.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "사진 앱에 저장되었습니다.",
                          imageName: "Union")
        alertToast.vm.alert.accept(alert)
        
        self.present(alertToast, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.dismiss(animated: false)
                }
            }
        }
    }
    
    /* 삭제 전 */
    func presentRemoveAlert(moment: Moment) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "삭제한 기록은 복원이 불가합니다.\n정말로 삭제하시겠어요?",
                          runButtonTitle: "삭제",
                          cancelButtonTitle: "취소")
        alertVC.vm.alert.accept(alert)
        alertVC.addCancelButton() { self.dismiss(animated: false) }
        alertVC.addRunButton(color: UIColor.errorRed) {
            self.dismiss(animated: false)
            Repository.instance.remove(moment: moment)
            self.presentRemoveToast()
        }
        
        self.present(alertVC, animated: false)
    }
    
    /* 삭제 완료 */
    func presentRemoveToast() {
        guard let alertToast = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertToast.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "삭제되었습니다.")
        alertToast.vm.alert.accept(alert)
        
        self.present(alertToast, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.dismiss(animated: false)
                    if self.viewModel.moments.value.count <= 0 {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
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
