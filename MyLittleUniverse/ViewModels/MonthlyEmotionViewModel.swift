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
    let moments = BehaviorSubject<[Moment]>(value: [])
    let emotionString: Observable<String>
    let numOfDayString: Observable<String>
    let dateString: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init(date: Date, emotion: Emotion) {
        let date = Observable.just(date)
        
        emotionString = Observable.just(emotion.word)
        numOfDayString = moments.map { "for \($0.count) days" }
        dateString = date.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY.MM"
            return formatter.string(from: $0)
        }
    }
}
