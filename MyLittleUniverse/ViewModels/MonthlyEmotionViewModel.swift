//
//  MonthlyEmotionViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/04/03.
//

import Foundation

import RxSwift
import RxCocoa

class MonthlyEmotionViewModel {
    let moments: BehaviorRelay<[Moment]>
    let isLatest = BehaviorRelay<Bool>(value: true)
    
    let emotionString: Observable<String>
    let numOfDayString: Observable<String>
    let dateString: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init(emotion: Emotion) {
        let date = Date()
        
        let savedMoments = Repository.instance.moments.value.filter {
                    $0.year == $0.year &&
                    $0.month == date.month &&
                    $0.emotion == emotion
                }
        moments = BehaviorRelay(value: savedMoments)
        
        emotionString = Observable.just(emotion.word)
        numOfDayString = moments.map { "for \($0.count) days" }
        dateString = Observable.of("\(date.year).\(date.month)")
        
        isLatest
            .map { isLatestOrder -> [Moment] in
                var moments = self.moments.value
                if isLatestOrder {
                    moments = moments.sorted { $0.timeStamp > $1.timeStamp }
                } else {
                    moments = moments.sorted { $0.timeStamp < $1.timeStamp }
                }
                return moments
            }
            .subscribe(onNext: moments.accept(_:))
            .disposed(by: disposeBag)
    }
}
