//
//  Route.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/05.
//

import UIKit

class Route {
    enum ViewId: String {
        case nickNameVC = "nickNameView"
        case initVC = "initView"
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
    
    static func switchHome() {
        let homeVC = Route.getVC(.monthlyVC)
        UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: homeVC)
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}


