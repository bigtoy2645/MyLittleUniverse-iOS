//
//  SceneDelegate.swift
//  MyLittleUniverse
//
//  Created by yurim on 2021/11/09.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 꾸미기 중 날짜 변경된 경우 감정 선택 화면으로 이동
        if let paintListVC = UIApplication.topViewController() as? PaintEmotionListVC {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY.MM.dd"
            
            let paintTimeString = formatter.string(from: paintListVC.vm.timeStamp.value)
            let currentTimeString = formatter.string(from: Date())
            if paintTimeString != currentTimeString {
                Route.pushVC(.selectStatusVC, from: paintListVC)
            }
        }
        
        // 애플 로그인 만료된 경우 로그인 화면으로 이동
        if let identifier = Repository.instance.session.value?.identifier,
           let identifierData = Data(base64Encoded: identifier),
           let userId = String(data: identifierData, encoding: .utf8),
           let topVC = UIApplication.topViewController() {
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userId) { (credentialState, error) in
                if credentialState == .revoked {
                    Repository.instance.closeSession()
                    DispatchQueue.main.async {
                        Route.pushVC(.loginVC, from: topVC)
                    }
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
