//
//  UIImageView+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/13.
//

import UIKit
import Alamofire

extension UIImage {
    static func download(from url: String, completion: @escaping ((UIImage?) -> Void)) {
        AF.download(url)
            .downloadProgress { progress in
                // NSLog("Download Progress: \(progress.fractionCompleted)")
            }.response { response in
                if response.error == nil, let imagePath = response.fileURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    completion(image)
                } else {
                    // NSLog("impossibleToGetImageData")
                    completion(nil)
                }
            }
    }
}
