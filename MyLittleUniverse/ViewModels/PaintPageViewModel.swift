//
//  PaintPageViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/06/05.
//

import UIKit
import RxSwift
import RxCocoa

class PaintPageViewModel {
    let emotions = BehaviorRelay<[Emotion]>(value: [])
    let views = BehaviorRelay<[UIViewController]>(value: [])
    let currentIndex = BehaviorRelay<Int>(value: 0)
    let currentView = BehaviorRelay<PaintVC?>(value: nil)
    private let disposeBag = DisposeBag()
    
    init() {
        emotions
            .subscribe(onNext: { emotions in
                self.views.accept([])
                for index in 0..<emotions.count {
                    if let paintVC = Route.getVC(.paintVC) as? PaintVC {
                        paintVC.vm.emotion.accept(emotions[index])
                        var views = self.views.value
                        views.append(paintVC)
                        self.views.accept(views)
                        self.currentIndex.accept(0)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        currentIndex
            .map { self.views.value[safe: $0] as? PaintVC }
            .subscribe(onNext: currentView.accept(_:))
            .disposed(by: disposeBag)
    }
}
