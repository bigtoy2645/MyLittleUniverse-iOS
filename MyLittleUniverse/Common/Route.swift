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
        case loginVC = "loginView"
        case nameVC = "nickNameView"
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
    
    static func getClass(_ viewId: ViewId) -> AnyClass {
        switch viewId {
        case .splashVC:             return SplashVC.self
        case .loginVC:              return LoginVC.self
        case .nameVC:               return NameVC.self
        case .initVC:               return InitVC.self
        case .newMonthVC:           return NewMonthVC.self
        case .alertVC:              return AlertVC.self
        case .monthlyVC:            return MonthlyVC.self
        case .monthlyEmotionVC:     return MonthlyEmotionVC.self
        case .selectEmotionsVC:     return SelectEmotionsVC.self
        case .paintVC:              return PaintVC.self
        case .paintEmotionListVC:   return PaintEmotionListVC.self
        case .paintPageVC:          return PaintPageVC.self
        case .colorChipVC:          return ColorChipVC.self
        case .pictureStickerVC:     return PictureStickerVC.self
        case .shapeStickerVC:       return ShapeStickerVC.self
        case .textStickerVC:        return TextStickerVC.self
        case .clippingStickerVC:    return ClippingPictureStickerVC.self
        case .selectStatusVC:       return SelectStatusVC.self
        case .myPageVC:             return MyPageVC.self
        case .myUniverseVC:         return MyUniverseVC.self
        case .cardVC:               return CardVC.self
        case .cardDetailVC:         return CardDetailVC.self
        }
    }
    
    /* ViewController */
    static func getVC(_ viewId: ViewId) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: viewId.rawValue)
    }
    
    /* 특정 ViewController로 이동 */
    static func pushVC(_ viewId: ViewId, from vc: UIViewController) {
        let classType: AnyClass = Route.getClass(viewId)
        
        guard let navigationController = vc.navigationController,
              !vc.isKind(of: classType) else {
            return
        }
        
        var isExists = false
        for controller in navigationController.viewControllers {
            if controller.isKind(of: classType) {
                navigationController.popToViewController(controller, animated: false)
                isExists = true
                break
            }
        }
        if !isExists {
            let selectVC = Route.getVC(viewId)
            navigationController.pushViewController(selectVC, animated: false)
        }
    }
    
    static func switchHome() {
        let homeVC = Route.getVC(.monthlyVC)
        UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: homeVC)
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}


