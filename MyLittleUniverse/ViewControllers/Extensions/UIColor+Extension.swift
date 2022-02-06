//
//  UIColor+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/06.
//

import UIKit

extension UIColor {
    static let bgGreen = UIColor(named: "BackgroundGreen")
    static let pointPurple = UIColor(named: "PointPurple")
    static let pointYellow = UIColor(named: "PointYellow")
    
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
