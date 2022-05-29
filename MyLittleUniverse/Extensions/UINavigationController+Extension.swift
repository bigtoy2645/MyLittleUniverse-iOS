//
//  UINavigationController+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/29.
//

import UIKit

extension UINavigationController {
    func popToVC(_ vc: AnyClass, animated: Bool = false) {
        for controller in viewControllers {
            if controller.isKind(of: vc) {
                popToViewController(controller, animated: false)
                break
            }
        }
    }
}
