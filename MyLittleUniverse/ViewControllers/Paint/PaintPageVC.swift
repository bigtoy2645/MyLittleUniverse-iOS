//
//  PageViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/03.
//

import UIKit
import RxSwift
import RxCocoa

class PaintPageVC: UIPageViewController {
    var emotions = BehaviorRelay<[Emotion]>(value: [])
    var views = [UIViewController]()
    var currentIndex = BehaviorRelay<Int>(value: 0)
    let currentView = BehaviorRelay<PaintVC?>(value: nil)
    var pageSwitchHandler: ((Int) -> ())?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setupBindings()
        
        if let firstVC = views.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    /* Index의 ViewController로 전환 */
    func switchViewController(from index: Int) {
        if index < 0, index >= views.count { return }
        
        setViewControllers([views[index]], direction: .forward, animated: false, completion: nil)
        currentIndex.accept(index)
        pageSwitchHandler?(currentIndex.value)
    }
    
    /* Binding */
    func setupBindings() {
        emotions
            .subscribe(onNext: { emotions in
                self.views.removeAll()
                for index in 0..<emotions.count {
                    if let paintVC = Route.getVC(.paintVC) as? PaintVC {
                        paintVC.viewModel.emotion.accept(emotions[index])
                        self.views.append(paintVC)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        currentIndex
            .map { self.views[$0] as? PaintVC }
            .subscribe(onNext: currentView.accept(_:))
            .disposed(by: disposeBag)
    }
}

// MARK: - DataSource, Delegate

extension PaintPageVC: UIPageViewControllerDelegate {
    /* 이전 View로 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = views.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = index - 1
        if previousIndex < 0 { return nil }
        currentIndex.accept(previousIndex)
        
        return views[previousIndex]
    }
    
    /* 다음 View로 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = views.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = index + 1
        if nextIndex == views.count { return nil }
        currentIndex.accept(nextIndex)
        
        return views[nextIndex]
    }
    
    /* View 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageSwitchHandler?(currentIndex.value)
        }
    }
}
