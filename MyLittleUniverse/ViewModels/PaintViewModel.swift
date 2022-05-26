//
//  PaintViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/25.
//

import Foundation
import RxSwift
import RxCocoa

struct Handler {
    let undo: (() -> Void)
    let redo: (() -> Void)
}

class PaintViewModel {
    let bgHexColor = BehaviorRelay<Int>(value: 0xFFFFFF)
    let emotion = BehaviorRelay<Emotion>(value: Emotion.empty)
    let bgColor = BehaviorSubject<UIColor>(value: .white)
    
    private let disposeBag = DisposeBag()
    
    init() {
        bgHexColor.map { UIColor(rgb: $0) }
            .bind(to: bgColor)
            .disposed(by: disposeBag)
    }
}
