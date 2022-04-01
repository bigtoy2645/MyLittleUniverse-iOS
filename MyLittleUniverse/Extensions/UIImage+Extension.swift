//
//  UIImageView+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit
import Alamofire

extension UIImage {
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
