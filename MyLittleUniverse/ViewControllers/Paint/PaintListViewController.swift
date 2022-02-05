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
    
    let emotions = BehaviorSubject<[Emotion]>(value: [])
    var disposeBag = DisposeBag()
    
    var pageViewController = PaintPageViewController()
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        colEmotion.selectItem(at: IndexPath(row: 0, section: 0),
                              animated: false,
                              scrollPosition: .left)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
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
            .subscribe(onNext: { index in
                self.pageViewController.switchViewController(from: index.row)
            })
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageSegue" {
            guard let paintPageVC = segue.destination as? PaintPageViewController else { return }
            do {
                pageViewController = paintPageVC
                pageViewController.pageCount = try emotions.value().count
                pageViewController.completeHandler = { (index) in
                    self.selectedIndex = index
                }
            } catch let error {
                NSLog("Failed to get emotion values. Error = \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colEmotion: UICollectionView!
}
