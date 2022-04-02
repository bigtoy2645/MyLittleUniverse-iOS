//
//  PaintPageViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/29.
//

import UIKit
import RxSwift

class PaintListViewController: UIViewController, UICollectionViewDelegate {
    static let storyboardID = "paintListView"
    
    var pageViewController = PaintPageViewController()
    let emotions = BehaviorSubject<[Emotion]>(value: [])
    var selectedIndex = BehaviorSubject(value: 0)
    var disposeBag = DisposeBag()
    
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
            .bind(to: colEmotion.rx.items(cellIdentifier: PaintEmotionCollectionViewCell.identifier,
                                          cellType: PaintEmotionCollectionViewCell.self)) { index, emotion, cell in
                cell.lblEmotion.text = emotion.rawValue
            }
            .disposed(by: disposeBag)
        
        colEmotion.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { indexPath in
                self.pageViewController.switchViewController(from: indexPath.row)
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
        
        // 완료
        btnSaveAll.rx.tap
            .bind {
                guard let alertVC = self.storyboard?.instantiateViewController(withIdentifier: AlertViewController.storyboardID) as? AlertViewController else { return }
                
                alertVC.modalPresentationStyle = .overFullScreen
                let alert = Alert(title: "꾸미기가 진행된 단어만 저장됩니다.",
                                  subtitle: "완료하지 못한 단어는\n오늘 다시 등록하면 꾸밀 수 있어요.",
                                  runButtonTitle: "저장",
                                  cancelButtonTitle: "취소")
                alertVC.vm.alert.accept(alert)
                alertVC.addCancelButton() { self.dismiss(animated: false) }
                alertVC.addRunButton(color: UIColor.mainBlack) {
                    self.dismiss(animated: false)
                    guard let alertToast = self.storyboard?.instantiateViewController(withIdentifier: AlertViewController.storyboardID) as? AlertViewController else { return }
                    
                    alertToast.modalPresentationStyle = .overFullScreen
                    let alert = Alert(title: "오늘의 감정이 모두 저장되었습니다.",
                                      imageName: "Union")
                    alertToast.vm.alert.accept(alert)
                    self.present(alertToast, animated: false) {
                        DispatchQueue.main.async {
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                self.dismiss(animated: false)
                                guard let controllers = self.navigationController?.viewControllers else { return }
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
                
                self.present(alertVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // 취소
        btnCancel.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {
                guard let alertVC = self.storyboard?.instantiateViewController(withIdentifier: AlertViewController.storyboardID) as? AlertViewController else { return }
                
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
            guard let paintPageVC = segue.destination as? PaintPageViewController else { return }
            do {
                pageViewController = paintPageVC
                pageViewController.pageCount = try emotions.value().count
                pageViewController.completeHandler = { (index) in
                    do {
                        if try index != self.selectedIndex.value() {
                            self.selectedIndex.onNext(index)
                        }
                    } catch let error {
                        NSLog("Failed to get selected page index. Error = \(error.localizedDescription)")
                    }
                }
            } catch let error {
                NSLog("Failed to get emotion values. Error = \(error.localizedDescription)")
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
