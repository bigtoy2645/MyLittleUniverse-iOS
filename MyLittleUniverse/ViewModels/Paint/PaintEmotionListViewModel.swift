//
//  PaintEmotionListViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/06.
//

import UIKit
import RxSwift
import RxCocoa

class PaintEmotionListViewModel {
    let emotions = BehaviorRelay<[Emotion]>(value: [])
    let selectedIndex = BehaviorRelay(value: 0)
    let timeStamp = BehaviorRelay<Date>(value: Date())
    let moments = BehaviorRelay<[Moment]>(value: [])
    let saveEnabled = BehaviorRelay<Bool>(value: false)
    let saveAllEnabled = BehaviorRelay<Bool>(value: false)
    let savedIndex = BehaviorRelay<Int>(value: -1)
    
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}
