//
//  SplashVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/07/05.
//

import UIKit
import Alamofire

class SplashVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
    }
    
    /* 업데이트 확인 */
    func checkForUpdates() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            pushNextViewController()
            return
        }
        
        let url = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        AF.request(url).responseJSON { response in
            guard let json = response.value as? NSDictionary,
                  let results = json["results"] as? NSArray,
                  let entry = results.firstObject as? NSDictionary,
                  let storeVersion = entry["version"] as? String else {
                NSLog("Failed to get store version. Repsonse = \(response)")
                self.pushNextViewController()
                return
            }
            guard let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                NSLog("Failed to get local version.")
                self.pushNextViewController()
                return
            }
            
            // 업데이트 필요
            if storeVersion.compare(localVersion, options: .numeric) == .orderedDescending {
                self.presentUpdateRequired()
            } else {
                self.pushNextViewController()
            }
        }
    }
    
    /* 다음 화면으로 이동 */
    func pushNextViewController() {
        let nextVC = Route.getVC(.loginVC)
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    /* 업데이트 권고 창 표시 */
    func presentUpdateRequired() {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "새로운 버전 알림",
                          subtitle: "더 나은 감정 발견을 위한 기능이 추가되었습니다.\n지금 바로 업데이트해보세요!",
                          runButtonTitle: "업데이트",
                          cancelButtonTitle: "취소")
        alertVC.vm.alert.accept(alert)
        alertVC.addCancelButton() {
            self.dismiss(animated: false)
            self.pushNextViewController()
        }
        alertVC.addRunButton(color: UIColor.mainBlack) {
            self.dismiss(animated: false)
            if !self.openAppStore() { self.pushNextViewController() }
        }
        
        self.present(alertVC, animated: false)
    }
    
    /* 앱스토어 열기 */
    func openAppStore() -> Bool {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1626273907"),
              UIApplication.shared.canOpenURL(url) else { return false }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}
