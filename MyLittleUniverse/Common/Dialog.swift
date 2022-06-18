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
            Repository.instance.remove(moment: moment)
            Dialog.presentRemoveToast(viewController, completion: completion)
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
}
