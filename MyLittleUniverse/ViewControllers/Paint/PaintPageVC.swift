//
//  PageViewController.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/03.
//

import UIKit

class PaintPageVC: UIPageViewController {
    static let storyboardID = "paintPageView"
    
    var emotions: [Emotion] = [] {
        didSet {
            views.removeAll()
            for index in 0..<emotions.count {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                if let paintVC = storyBoard.instantiateViewController(identifier: PaintViewController.storyboardID) as? PaintViewController {
                    paintVC.emotion = emotions[index]
                    views.append(paintVC)
                }
            }
        }
    }
    var completeHandler: ((Int) -> ())?
    
    var views = [UIViewController]()
    var currentIndex : Int {
        guard let vc = viewControllers?.first,
              let index = views.firstIndex(of: vc) else { return 0 }
        return index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if let firstVC = views.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    /* Index의 ViewController로 전환 */
    func switchViewController(from index: Int) {
        if index < 0, index >= views.count { return }
        
        setViewControllers([views[index]], direction: .forward, animated: false, completion: nil)
        completeHandler?(currentIndex)
    }
}

// MARK: - DataSource, Delegate

extension PaintPageVC: UIPageViewControllerDelegate {
    /* 이전 View로 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = views.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = index - 1
        if previousIndex < 0 { return nil }
        
        return views[previousIndex]
    }
    
    /* 다음 View로 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = views.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = index + 1
        if nextIndex == views.count { return nil }
        
        return views[nextIndex]
    }
    
    /* View 전환 */
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            completeHandler?(currentIndex)
        }
    }
}
