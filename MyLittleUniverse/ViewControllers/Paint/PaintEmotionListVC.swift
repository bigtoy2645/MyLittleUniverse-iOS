//
//  PaintPageViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/29.
//

import UIKit
import RxSwift
import RxCocoa

class PaintEmotionListVC: UIViewController, UICollectionViewDelegate {
    var pageVC = PaintPageVC()
    let vm = PaintEmotionListViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 0.4]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = saveView.bounds
        saveView.layer.mask = gradientLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEmotionScroll()
        
        let stickerHeight = view.frame.height - containerView.frame.origin.y - containerView.frame.width - 64
        if stickerHeight < containerView.frame.width / 2 {
            heightConstraint.constant = view.frame.height + containerView.frame.width / 2 - stickerHeight
            scrollView.isScrollEnabled = true
        } else {
            heightConstraint.constant = scrollView.frame.height
            scrollView.isScrollEnabled = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateEmotionScroll()
    }
    
    /* Binding */
    func setupBindings() {
        colEmotion.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        vm.emotions
            .bind(to: colEmotion.rx.items(cellIdentifier: PaintEmotionCell.identifier,
                                          cellType: PaintEmotionCell.self)) { index, emotion, cell in
                cell.lblEmotion.text = emotion.word
            }
                                          .disposed(by: disposeBag)
        
        colEmotion.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { indexPath in
                self.pageVC.switchViewController(from: indexPath.row)
            })
            .disposed(by: disposeBag)
        
        vm.selectedIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.colEmotion.selectItem(at: IndexPath(row: $0, section: 0),
                                           animated: true,
                                           scrollPosition: .left)
            })
            .disposed(by: disposeBag)
        
        // 스티커 있을 때 저장 버튼 활성화
        pageVC.vm.views.value.forEach { vc in
            guard let vc = vc as? PaintVC else { return }
            vc.vm.stickers
                .map { stickers -> Bool in
                    if self.pageVC.vm.currentView.value == vc { return stickers.count > 0 }
                    return self.btnSave.isEnabled
                }
                .bind(to: vm.saveEnabled)
                .disposed(by: disposeBag)
        }
        pageVC.vm.currentView
            .map { vc -> Bool in
                guard let stickerCount = vc?.vm.stickers.value.count else { return self.btnSave.isEnabled }
                return stickerCount > 0
            }
            .bind(to: vm.saveEnabled)
            .disposed(by: disposeBag)
        
        // 저장
        vm.saveEnabled
            .bind(to: btnSave.rx.isEnabled)
            .disposed(by: disposeBag)
        
        vm.saveEnabled
            .map { $0 ? UIColor.white : UIColor.white.withAlphaComponent(0.1) }
            .bind(to: btnSave.rx.tintColor)
            .disposed(by: disposeBag)
        
        btnSave.rx.tap
            .bind {
                self.vm.saveAllEnabled.accept(true)
                self.pageVC.vm.currentView.value?.vm.focusSticker.accept(nil)
                guard let paintVC = self.pageVC.vm.currentView.value,
                      let paintImageData = paintVC.paintView.asImage().pngData() else { return }
                
                let bgColor = paintVC.vm.bgHexColor.value
                var textLabel = ""
                var textColor = UIColor(rgb: bgColor).isLight() ? 0x000000 : 0xFFFFFF
                
//                if let textSticker = paintVC.labelSticker.stickerView as? UILabel {
//                    textLabel = textSticker.text ?? ""
//                    if !textLabel.isEmpty {
//                        textColor = textSticker.textColor.rgb() ?? textColor
//                    }
//                }
                let moment = Moment(timeStamp: self.vm.timeStamp.value.timeIntervalSinceReferenceDate,
                                    emotion: paintVC.vm.emotion.value,
                                    text: textLabel,
                                    textColor: textColor,
                                    imageData: paintImageData,
                                    bgColor: bgColor)
                
                var newMoments = self.vm.moments.value
                if let momentIndex = newMoments.firstIndex(of: moment) {
                    newMoments[momentIndex] = moment
                } else {
                    newMoments.append(moment)
                }
                self.vm.moments.accept(newMoments)
                
                // 저장 완료
                paintVC.view.endEditing(true)
                self.presentSavedView(paintVC.paintView)
            }
            .disposed(by: disposeBag)
        
        // 완료
        vm.saveAllEnabled
            .bind(to: btnSaveAll.rx.isEnabled)
            .disposed(by: disposeBag)
        
        vm.saveAllEnabled
            .map { $0 ? UIColor.white : UIColor.white.withAlphaComponent(0.1) }
            .bind { self.btnSaveAll.setTitleColor($0, for: .normal) }
            .disposed(by: disposeBag)
        
        btnSaveAll.rx.tap
            .bind {
                if self.vm.moments.value.count == self.vm.emotions.value.count {
                    self.presentSavedAlert()
                } else {
                    guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
                    
                    let alert = Alert(title: "꾸미기가 진행된 단어만 저장됩니다.",
                                      subtitle: "완료하지 못한 단어는\n오늘 다시 등록하면 꾸밀 수 있어요.",
                                      runButtonTitle: "저장",
                                      cancelButtonTitle: "취소")
                    alertVC.vm.alert.accept(alert)
                    alertVC.addCancelButton() { self.dismiss(animated: false) }
                    alertVC.addRunButton(color: UIColor.mainBlack) {
                        self.dismiss(animated: false)
                        self.presentSavedAlert()
                    }
                    alertVC.modalPresentationStyle = .overFullScreen
                    self.present(alertVC, animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        // 취소
        btnCancel.rx.tap
            .bind { self.presentCancelAlert() }
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageSegue" {
            guard let paintPageVC = segue.destination as? PaintPageVC else { return }
            pageVC = paintPageVC
            pageVC.vm.emotions.accept(vm.emotions.value)
            pageVC.pageSwitchHandler = { (index) in
                if index != self.vm.selectedIndex.value {
                    self.vm.selectedIndex.accept(index)
                }
            }
        }
    }
    
    /* 저장 완료 화면 */
    func presentSavedView(_ superView: UIView) {
        let saveView = UIView(frame: superView.bounds)
        saveView.backgroundColor = UIColor(rgb: 0x898989).withAlphaComponent(0.5)
        let lblDone = UILabel(frame: saveView.bounds)
        lblDone.text = "저장 완료!"
        lblDone.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lblDone.textColor = .white
        lblDone.sizeToFit()
        lblDone.center = saveView.center
        saveView.addSubview(lblDone)
        superView.addSubview(saveView)
        
        // 다음 감정 페이지로 이동
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            saveView.removeFromSuperview()
            DispatchQueue.main.async {
                var nextItem = self.vm.selectedIndex.value + 1
                if nextItem >= self.vm.emotions.value.count { nextItem = 0 }
                self.pageVC.switchViewController(from: nextItem)
            }
        }
    }
    
    /* 감정 목록 스크롤 */
    func updateEmotionScroll() {
        let contentSize = colEmotion.contentSize.width - colEmotion.frame.size.width - emotionTrailingConstraint.constant
        if colEmotion.contentOffset.x >= contentSize {
            emotionTrailingConstraint.constant = saveViewWidthConstraint.constant
        } else {
            emotionTrailingConstraint.constant = 10
        }
        
        if colEmotion.contentOffset.x > 0 {
            emotionLeadingConstraint.constant = 0
        } else {
            emotionLeadingConstraint.constant = 24
        }
    }
    
    /* 취소 다이얼로그 */
    func presentCancelAlert() {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        var isEmpty = true
        pageVC.vm.views.value.forEach { vc in
            guard let vc = vc as? PaintVC else { return }
            if vc.vm.stickers.value.count > 0 {
                isEmpty = false
            }
        }
        
        let alertTitle = isEmpty ?
        "선택하신 감정 단어도 모두 사라집니다.\n꾸미지 않고 종료하시겠어요?" :
        "아직 진행 중인 꾸미기가 있어요.\n저장하지 않고 종료하시겠어요?"
        let alert = Alert(title: alertTitle,
                          runButtonTitle: "종료",
                          cancelButtonTitle: "취소")
        alertVC.vm.alert.accept(alert)
        alertVC.addRunButton() {
            self.dismiss(animated: false)
            if SelectStatusVC.parentView is MyPageVC {
                _ = self.navigationController?.popToVC(MyPageVC.self)
            } else {
                _ = self.navigationController?.popToVC(MonthlyVC.self)
            }
        }
        alertVC.addCancelButton() {
            self.dismiss(animated: false)
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        self.present(alertVC, animated: false)
    }
    
    /* 감정 저장 다이얼로그 */
    func presentSavedAlert() {
        self.vm.moments.value.forEach { Repository.instance.add(moment: $0) }
        
        guard let alertToast = Route.getVC(.alertVC) as? AlertVC else { return }
        
        let alert = Alert(title: "오늘의 감정이 모두 저장되었습니다.", imageName: "Union")
        alertToast.vm.alert.accept(alert)
        alertToast.modalPresentationStyle = .overFullScreen
        self.present(alertToast, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.dismiss(animated: false)
                    guard let controllers = self.navigationController?.viewControllers else { return }
                    if controllers.filter({ $0 is MonthlyVC }).isEmpty {
                        let homeVC = Route.getVC(.monthlyVC)
                        self.navigationController?.pushViewController(homeVC, animated: false)
                    } else {
                        for vc in controllers {
                            if vc is MonthlyVC {
                                self.navigationController?.popToViewController(vc, animated: false)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnSaveAll: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var colEmotion: UICollectionView!
    @IBOutlet weak var emotionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var emotionTrailingConstraint: NSLayoutConstraint!
}
