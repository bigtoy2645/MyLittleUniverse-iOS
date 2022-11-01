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
    let moments = BehaviorRelay<[Moment]>(value: [])
    let isLatest = BehaviorRelay<Bool>(value: true)
    
    let emotionString: Observable<String>
    let numOfDayString: Observable<String>
    let dateString: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init(emotion: Emotion) {
        let date = Date()
        
        Repository.instance.monthlyMoments
            .map { $0.filter { $0.emotion == emotion } }
            .subscribe(onNext: moments.accept(_:))
            .disposed(by: disposeBag)
        
        emotionString = Observable.just(emotion.word)
        numOfDayString = moments.map { "for \($0.count) days" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM"
        dateString = Observable.of(formatter.string(from: date))
        
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
