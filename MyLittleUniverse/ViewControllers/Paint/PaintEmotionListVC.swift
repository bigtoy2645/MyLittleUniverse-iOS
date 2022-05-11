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
    let emotions = BehaviorRelay<[Emotion]>(value: [])
    var selectedIndex = BehaviorRelay(value: 0)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        btnSave.isEnabled = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 0.4]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = saveView.bounds
        saveView.layer.mask = gradientLayer
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width > (scrollView.bounds.origin.x + view.frame.width - saveView.frame.width * 0.6) ||
            scrollView.contentSize.width == 0 {
            emotionTrailingConstraint.constant = 10
        } else {
            emotionTrailingConstraint.constant = saveView.frame.width
        }
    }
    
    /* Binding */
    func setupBindings() {
        colEmotion.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        emotions
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
        
        selectedIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.colEmotion.selectItem(at: IndexPath(row: $0, section: 0),
                                           animated: true,
                                           scrollPosition: .left)
            })
            .disposed(by: disposeBag)
        
        // 스티커 있을 때 저장 버튼 활성화
//        pageVC.currentView.value.stickers
//            .map {
//                guard let stickerCount = $0.count else { return false }
//                return stickerCount > 0
//            }
//            .bind(to: btnSave.rx.isEnabled)
//            .disposed(by: disposeBag)
        
        // 저장
        btnSave.rx.tap
            .bind {
                self.pageVC.currentView.value?.focusSticker = nil
                guard let paintVC = self.pageVC.currentView.value,
                      let paintImageData = paintVC.paintView.asImage().pngData() else { return }
                var textLabel = "", textColor = 0x000000
                
                if let textSticker = paintVC.labelSticker.stickerView as? UILabel {
                    textLabel = textSticker.text ?? ""
                    textColor = textSticker.textColor.rgb() ?? 0x000000
                }
                let moment = Moment(emotion: paintVC.emotion,
                                    text: textLabel,
                                    textColor: textColor,
                                    imageData: paintImageData,
                                    bgColor: paintVC.bgColor.value)
                
                Repository.instance.add(moment: moment)
                // 저장 완료
                self.presentSavedView(paintVC.paintView)
            }
            .disposed(by: disposeBag)
        
        // 완료
        btnSaveAll.rx.tap
            .bind {
                guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
                
                alertVC.modalPresentationStyle = .overFullScreen
                let alert = Alert(title: "꾸미기가 진행된 단어만 저장됩니다.",
                                  subtitle: "완료하지 못한 단어는\n오늘 다시 등록하면 꾸밀 수 있어요.",
                                  runButtonTitle: "저장",
                                  cancelButtonTitle: "취소")
                alertVC.vm.alert.accept(alert)
                alertVC.addCancelButton() { self.dismiss(animated: false) }
                alertVC.addRunButton(color: UIColor.mainBlack) {
                    self.dismiss(animated: false)
                    guard let alertToast = Route.getVC(.alertVC) as? AlertVC else { return }
                    
                    alertToast.modalPresentationStyle = .overFullScreen
                    let alert = Alert(title: "오늘의 감정이 모두 저장되었습니다.",
                                      imageName: "Union")
                    alertToast.vm.alert.accept(alert)
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
                
                self.present(alertVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // 취소
        btnCancel.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
                
                alertVC.modalPresentationStyle = .overFullScreen
                let alert = Alert(title: "선택하신 감정 단어도 모두 사라집니다.\n꾸미지 않고 종료하시겠어요?",
                                  runButtonTitle: "종료",
                                  cancelButtonTitle: "취소")
                alertVC.vm.alert.accept(alert)
                alertVC.addRunButton() {
                    self.dismiss(animated: false)
                    self.navigationController?.popViewController(animated: false)
                }
                alertVC.addCancelButton() {
                    self.dismiss(animated: false)
                }
                
                self.present(alertVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageSegue" {
            guard let paintPageVC = segue.destination as? PaintPageVC else { return }
            pageVC = paintPageVC
            pageVC.emotions.accept(emotions.value)
            pageVC.pageSwitchHandler = { (index) in
                if index != self.selectedIndex.value {
                    self.selectedIndex.accept(index)
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
                var nextItem = self.selectedIndex.value + 1
                if nextItem >= self.emotions.value.count { nextItem = 0 }
                self.pageVC.switchViewController(from: nextItem)
            }
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colEmotion: UICollectionView!
    @IBOutlet weak var btnSaveAll: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var emotionTrailingConstraint: NSLayoutConstraint!
}