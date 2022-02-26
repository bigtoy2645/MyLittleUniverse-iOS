//
//  UIView+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/26.
//

import UIKit

extension UIView {
    /* 슬라이드 애니메이션으로 숨기기 */
    func hideWithAnimation(hidden: Bool) {
        let slideUp = CGAffineTransform(translationX: 0, y: 0)
        let slideDown = CGAffineTransform(translationX: 0, y: self.frame.height)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.transform = hidden ? slideDown : slideUp
        })
    }
}
