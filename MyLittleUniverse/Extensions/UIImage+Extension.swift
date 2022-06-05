//
//  UIImageView+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit
import Alamofire

extension UIImage {
    static let colorOn = UIImage(named: "edge/Color-On_24")
    static let colorOff = UIImage(named: "edge/Color-Off_24")
    static let colorDisabled = UIImage(named: "edge/Color-Disabled_24")
    static let editOn = UIImage(named: "edge/Edit-On_24")
    static let editOff = UIImage(named: "edge/Edit-Off_24")
    static let editDisabled = UIImage(named: "edge/Edit-Disabled_24")
    static let deleteOn = UIImage(named: "edge/Delete-On_24")
    static let deleteOff = UIImage(named: "edge/Delete-Off_24")
    static let deleteDisabled = UIImage(named: "edge/Delete-Disabled_24")
    static let cloneOn = UIImage(named: "edge/Clone-On_24")
    static let cloneOff = UIImage(named: "edge/Clone-Off_24")
    static let cloneDisabled = UIImage(named: "edge/Clone-Disabled_24")
    static let sizeOn = UIImage(named: "edge/Size-On_24")
    static let sizeOff = UIImage(named: "edge/Size-Off_24")
    static let sizeDisabled = UIImage(named: "edge/Size-Disabled_24")
    
    static let undoOn = UIImage(named: "Undo-On_24")
    static let undoOff = UIImage(named: "Undo-Off_24")
    static let redoOn = UIImage(named: "Redo-On_24")
    static let redoOff = UIImage(named: "Redo-Off_24")
    static let photoOn = UIImage(named: "Photo-On_24")
    static let photoOff = UIImage(named: "Photo-Off_24")
    static let lineShapeOn = UIImage(named: "Line-Shape-On_24")
    static let lineShapeOff = UIImage(named: "Line-Shape-Off_24")
    static let fillShapeOn = UIImage(named: "Fill-Shape-On_24")
    static let fillShapeOff = UIImage(named: "Fill-Shape-Off_24")
    static let textOn = UIImage(named: "Text-On_24")
    static let textOff = UIImage(named: "Text-Off_24")
    
    /* 이미지 다운로드 */
    static func download(from url: String, completion: @escaping ((UIImage?) -> Void)) {
        AF.download(url)
            .response { response in
                if response.error == nil, let imagePath = response.fileURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    NSLog("Image Downloaded. URL = \(url)")
                    completion(image)
                } else {
                    NSLog("Image download failed. error: \(response.error?.localizedDescription ?? "No error")")
                    completion(nil)
                }
            }
    }
    
    /* 클리핑마스크 이미지 */
    func clip(path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.addPath(path.cgPath)
            context.clip()
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
            return maskedImage
        }
        UIGraphicsEndImageContext()
        
        return nil
    }
}
