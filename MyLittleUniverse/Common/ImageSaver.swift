//
//  ImageSaver.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/19.
//

import UIKit
import Photos

class ImageSaver: NSObject {
    private var showSetting = false
    private var imageSavedHandler: (() -> Void)?
    private var viewController: UIViewController?
    
    /* 이미지 저장 */
    func saveImage(_ image: UIImage, target: UIViewController? = nil, handler: (() -> Void)? = nil) {
        imageSavedHandler = handler
        viewController = target
        
        checkAlbumPermission()
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(imageSaved(image:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    /* 이미지 저장 후 */
    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: Error, contextInfo: UnsafeMutableRawPointer?) {
        if error == nil {
            imageSavedHandler?()
        } else {
            NSLog("Failed to save image. Error = \(error.localizedDescription)")
            if showSetting, let vc = viewController {
                Dialog.presentPhotoPermission(vc)
            }
        }
    }
    
    /* 권한 체크 */
    private func checkAlbumPermission() {
        var status: PHAuthorizationStatus = .notDetermined
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        showSetting = status == .notDetermined
    }
}
