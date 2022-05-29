//
//  UIViewController+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/29.
//

import UIKit

extension UIViewController {
    func present(asChildViewController viewController: UIViewController, view: UIView) {
        if view.subviews.contains(viewController.view) {
            view.bringSubviewToFront(viewController.view)
            return
        }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
