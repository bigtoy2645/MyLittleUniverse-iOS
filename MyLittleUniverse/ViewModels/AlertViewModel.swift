//
//  AlertViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/09.
//

import Foundation
import RxSwift
import RxCocoa

class AlertViewModel {
    var alert = BehaviorRelay<Alert>(value: Alert.empty)
    let image: Observable<UIImage?>
    let hideSubtitle: Observable<Bool>
    let hideImage: Observable<Bool>
    let hideButtons: Observable<Bool>
    let hideRunButton: Observable<Bool>
    let hideCancelButton: Observable<Bool>
    
    init() {
        // 이미지
        image = alert.map({
            guard let imageName = $0.imageName else { return nil }
            return UIImage(named: imageName)
        })
        
        // 서브타이틀 숨김 여부
        hideSubtitle = alert.map({ $0.subtitle?.isEmpty ?? true })
        
        // 버튼 숨김 여부
        hideButtons = alert
            .map { alert -> Bool in
                let runButtonIsEmpty = alert.runButtonTitle?.isEmpty ?? true
                let cancelButtonIsEmpty = alert.cancelButtonTitle?.isEmpty ?? true
                return runButtonIsEmpty && cancelButtonIsEmpty
            }
        
        // 실행 버튼 숨김
        hideRunButton = alert.map({ $0.runButtonTitle?.isEmpty ?? true })
        
        // 취소 버튼 숨김
        hideCancelButton = alert.map({ $0.cancelButtonTitle?.isEmpty ?? true })
        
        // 이미지 숨김
        hideImage = alert.map({ $0.imageName == nil })
    }
}
