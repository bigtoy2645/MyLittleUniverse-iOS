//
//  UIView+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/02/26.
//

import UIKit

extension UIView {
    enum ShadowLocation {
        case top
        case bottom
        case left
        case right
    }
    
    /* 그림자 추가 */
    func addShadow(location: ShadowLocation,
                   color: UIColor = UIColor.disableGray,
                   opacity: Float = 0.3,
                   radius: CGFloat = 5.0) {
        switch location {
        case .top:
            addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 3), color: color, opacity: opacity, radius: radius)
        case .left:
            addShadow(offset: CGSize(width: -3, height: 0), color: color, opacity: opacity, radius: radius)
        case .right:
            addShadow(offset: CGSize(width: 3, height: 0), color: color, opacity: opacity, radius: radius)
        }
    }
    
    /* 그림자 추가 */
    func addShadow(offset: CGSize, color: UIColor, opacity: Float, radius: CGFloat) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    /* UIImage로 변환 */
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    /* 도트 무늬 라인 */
    func createDottedLine(width: CGFloat, color: CGColor) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = [3, 5]
        
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint.zero, CGPoint(x: frame.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        shapeLayer.path = cgPath
        layer.sublayers = [shapeLayer]
    }
}
