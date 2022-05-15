//
//  UIColor+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/06.
//

import UIKit

extension UIColor {
    static let bgGreen = UIColor(named: "BackgroundGreen")
    static let bgGreen70 = UIColor(named: "BackgroundGreen70")
    static let pointPurple = UIColor(named: "PointPurple")
    static let pointYellow = UIColor(named: "PointYellow")
    static let pointLightYellow = UIColor(named: "PointLightYellow")
    static let mainBlack = UIColor(named: "MainBlack") ?? .black
    static let errorRed = UIColor(named: "ErrorRed")
    static let mediumGray = UIColor(named: "MediumGray")
    static let disableGray = UIColor(named: "DisableGray") ?? .systemGray6
    
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
    
    /* RGB Hex */
    func rgb() -> Int? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let iRed = Int(red * 255.0)
            let iGreen = Int(green * 255.0)
            let iBlue = Int(blue * 255.0)
            let iAlpha = Int(alpha * 255.0)
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        }
        
        return nil
    }
    
    func isLight(threshold: Float = 0.5) -> Bool {
        let originalCGColor = self.cgColor
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        
        guard let components = RGBCGColor?.components,
              components.count >= 3 else {
            return true
        }
        
        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
