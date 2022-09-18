//
//  Route.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/05.
//

import UIKit

class Route {
    enum ViewId: String {
        case splashVC = "splashView"
        case nickNameVC = "nickNameView"
        case initVC = "initView"
        case newMonthVC = "newMonthView"
        case alertVC = "alertView"
        case monthlyVC = "homeView"
        case monthlyEmotionVC = "detailView"
        case selectEmotionsVC = "selectEmotionsView"
        case paintVC = "paintView"
        case paintEmotionListVC = "paintListView"
        case paintPageVC = "paintPageView"
        case colorChipVC = "paintColorChipView"
        case pictureStickerVC = "paintPictureStickerView"
        case shapeStickerVC = "paintShapeStickerView"
        case textStickerVC = "paintTextView"
        case clippingStickerVC = "paintClippingPictureStickerView"
        case selectStatusVC = "selectStatusView"
        case myPageVC = "myPageView"
        case myUniverseVC = "myUniverseView"
        case cardVC = "cardView"
        case cardDetailVC = "cardDetailView"
    }
    
    /* ViewController */
    static func getVC(_ viewId: ViewId) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: viewId.rawValue)
    }
    
    /* 감정 선택 화면으로 이동 */
    static func popToSelectStatusViewController(_ vc: UIViewController) {
        guard let navigationController = vc.navigationController,
              !(vc is SelectStatusVC) else {
            return
        }
        
        var isExists = false
        for controller in navigationController.viewControllers {
            if controller is SelectStatusVC {
                navigationController.popToViewController(controller, animated: false)
                isExists = true
                break
            }
        }
        if !isExists {
            let selectVC = Route.getVC(.selectStatusVC)
            navigationController.pushViewController(selectVC, animated: false)
        }
    }
    
    static func switchHome() {
        let homeVC = Route.getVC(.monthlyVC)
        UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: homeVC)
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}


