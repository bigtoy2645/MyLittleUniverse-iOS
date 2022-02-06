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
    
    let gradientLayer = CAGradientLayer()
    var pageViewController = PaintPageViewController()
    let emotions = BehaviorSubject<[Emotion]>(value: [])
    var selectedIndex = BehaviorSubject(value: 0)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = colEmotion.bounds
        colEmotion.layer.mask = gradientLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gradientLayer.frame = scrollView.bounds
        if scrollView.contentSize.width > (scrollView.bounds.origin.x + view.frame.width) {
            colEmotion.layer.mask = gradientLayer
        } else {
            colEmotion.layer.mask = nil
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
        
        btnSave.rx.tap
            .bind {
                guard let controllers = self.navigationController?.viewControllers else { return }
                for vc in controllers {
                    if vc is HomeViewController {
                        self.navigationController?.popToViewController(vc, animated: false)
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
        
        btnClose.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: false)
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
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnClose: UIBarButtonItem!
}
