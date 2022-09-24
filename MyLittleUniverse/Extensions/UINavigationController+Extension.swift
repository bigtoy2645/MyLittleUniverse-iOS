//
//  UINavigationController+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/29.
//

import UIKit

extension UINavigationController {    
    func searchVC(_ vc: AnyClass) -> UIViewController? {
        for controller in viewControllers {
            if controller.isKind(of: vc) {
                return controller
            }
        }
        return nil
    }
    
    var previousViewController: UIViewController? {
       viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil
    }
}
