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
    let vm = PaintPageViewModel()
    var pageSwitchHandler: ((Int) -> ())?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setupBindings()
        
        if let firstVC = vm.views.value.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    /* Index의 ViewController로 전환 */
    func switchViewController(from index: Int) {
        if index < 0, index >= vm.views.value.count { return }
        
        setViewControllers([vm.views.value[index]], direction: .forward, animated: false, completion: nil)
        vm.currentIndex.accept(index)
        pageSwitchHandler?(vm.currentIndex.value)
    }
    
    /* Binding */
    func setupBindings() {
        
    }
}

// MARK: - DataSource, Delegate

extension PaintPageVC: UIPageViewControllerDelegate {
    /* 이전 View로 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = vm.views.value.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = index - 1
        if previousIndex < 0 { return nil }
        vm.currentIndex.accept(previousIndex)
        
        return vm.views.value[previousIndex]
    }
    
    /* 다음 View로 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = vm.views.value.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = index + 1
        if nextIndex == vm.views.value.count { return nil }
        vm.currentIndex.accept(nextIndex)
        
        return vm.views.value[nextIndex]
    }
    
    /* View 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageSwitchHandler?(vm.currentIndex.value)
        }
    }
}
