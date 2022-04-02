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
    
    let disposeBag = DisposeBag()
    
    init(date: Date, emotion: Emotion) {
        let date = Observable.just(date)
        
        // TODO - date, emotion 해당하는 데이터 불러오기
        moments.onNext([Moment(emotion: emotion, date: Date(), description: "description1", image: ""),
                        Moment(emotion: emotion, date: Date(), description: "description2", image: ""),
                        Moment(emotion: emotion, date: Date(), description: "description3", image: ""),
                        Moment(emotion: emotion, date: Date(), description: "description4", image: "")])
        
        let emotion = Observable.just(emotion)
        
        emotionString = emotion.map { $0.rawValue }
        numOfDayString = moments.map { "for \($0.count) days" }
        dateString = date.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY.MM"
            return formatter.string(from: $0)
        }
    }
}
