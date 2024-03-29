//
//  Alert.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/15.
//

import Foundation
import UIKit

class Dialog {
    /* 기록 보관하기 클릭 시 */
    static func presentTBD(_ viewController: UIViewController) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "열심히 준비 중입니다.\n업데이트가 완료되면 알려드릴게요!")
        alertVC.vm.alert.accept(alert)
        viewController.present(alertVC, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    viewController.dismiss(animated: false)
                }
            }
        }
    }
    
    /* 사진 저장 알림 */
    static func presentImageSaved(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let alertToast = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertToast.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "사진 앱에 저장되었습니다.",
                          imageName: "Union")
        alertToast.vm.alert.accept(alert)
        
        viewController.present(alertToast, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    viewController.dismiss(animated: false)
                    completion?()
                }
            }
        }
    }
    
    /* 삭제 전 */
    static func presentRemove(_ viewController: UIViewController, moment: Moment, completion: (() -> Void)? = nil) {
        if !DataManager.isNetworkConnected() {
            Dialog.presentNetworkFailure(viewController)
            return
        }
        
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "삭제한 기록은 복원이 불가합니다.\n정말로 삭제하시겠어요?",
                          runButtonTitle: "삭제",
                          cancelButtonTitle: "취소")
        alertVC.vm.alert.accept(alert)
        alertVC.addCancelButton() {
            viewController.dismiss(animated: false)
        }
        alertVC.addRunButton(color: UIColor.errorRed) {
            viewController.dismiss(animated: false)
            Repository.instance.remove(moment: moment) { result in
                if result {
                    Dialog.presentRemoveToast(viewController, completion: completion)
                } else {
                    Dialog.presentTempError(viewController)
                }
            }
        }
        
        viewController.present(alertVC, animated: false)
    }
    
    /* 삭제 완료 */
    static func presentRemoveToast(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let alertToast = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertToast.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "삭제되었습니다.")
        alertToast.vm.alert.accept(alert)
        
        viewController.present(alertToast, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    viewController.dismiss(animated: false)
                    completion?()
                }
            }
        }
    }
    
    /* 사진 권한 설정 */
    static func presentPhotoPermission(_ viewController: UIViewController) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "감정 카드 저장을 원하시면\n설정에서 사진 접근을 허용하세요.",
                          subtitle: "설정 - 마이리틀유니버스 - 사진 접근 허용",
                          imageName: "Caution_32",
                          runButtonTitle: "설정")
        alertVC.vm.alert.accept(alert)
        alertVC.addRunButton(color: UIColor.mainBlack) {
            viewController.dismiss(animated: false)
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    NSLog("Settings opened: \(success)")
                })
            }
        }
        
        viewController.present(alertVC, animated: false)
    }
    
    /* 로그아웃 */
    static func presentLogout(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "정말 로그아웃 하시겠어요?",
                          runButtonTitle: "로그아웃",
                          cancelButtonTitle: "취소")
        alertVC.vm.alert.accept(alert)
        alertVC.addCancelButton() {
            viewController.dismiss(animated: false)
        }
        alertVC.addRunButton(color: UIColor.errorRed) {
            viewController.dismiss(animated: false)
            Repository.instance.closeSession()
            Route.pushVC(.loginVC, from: viewController)
        }
        
        viewController.present(alertVC, animated: false)
    }
    
    /* 탈퇴 */
    static func presentResign(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "추후 동일한 계정으로 재가입하더라도\n감정 기록 복구가 불가합니다.\n계정을 삭제하시겠어요?",
                          runButtonTitle: "삭제",
                          cancelButtonTitle: "취소")
        alertVC.vm.alert.accept(alert)
        alertVC.addCancelButton() {
            viewController.dismiss(animated: false)
        }
        alertVC.addRunButton(color: UIColor.errorRed) {
            viewController.dismiss(animated: false)
            if !DataManager.isNetworkConnected() {
                Dialog.presentNetworkFailure(viewController)
                return
            }
            Repository.instance.resignSession {
                Route.pushVC(.loginVC, from: viewController)
            }
        }
        
        viewController.present(alertVC, animated: false)
    }
    
    /* 네트워크 연결 실패 */
    static func presentNetworkFailure(_ viewController: UIViewController) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "네트워크 연결에 실패하였습니다.\n잠시 후 다시 시도해주세요.",
                          imageName: "Caution_32",
                          runButtonTitle: "확인")
        alertVC.vm.alert.accept(alert)
        alertVC.addRunButton(color: .mainBlack) {
            viewController.dismiss(animated: false)
        }
        
        viewController.present(alertVC, animated: false)
    }
    
    /* 일시적 오류 발생 */
    static func presentTempError(_ viewController: UIViewController) {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "일시적인 오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.",
                          imageName: "Caution_32",
                          runButtonTitle: "확인")
        alertVC.vm.alert.accept(alert)
        alertVC.addRunButton(color: .mainBlack) {
            viewController.dismiss(animated: false)
        }
        
        viewController.present(alertVC, animated: false)
    }
}
