//
//  MonthlyViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/19.
//

import Foundation
import RxSwift
import RxCocoa

class MonthlyViewModel {
    let recoredDays: Observable<[Int]>
    let emotions: Observable<[Emotion: Int]>
    let monthString: Observable<String>
    
    let disposeBag = DisposeBag()
    
    init(date: Date) {
        let date = Observable.just(date)
        let moments = BehaviorSubject<[Int: [Moment]]>(value: [:])
        
        // TODO - date 해당하는 데이터 불러오기
        moments.onNext([1: [Moment(emotion: positiveEmotions[0], date: Date(), description: "", image: ""),
                            Moment(emotion: positiveEmotions[1], date: Date(), description: "", image: "")],
                        10: [Moment(emotion: positiveEmotions[1], date: Date(), description: "", image: ""),
                             Moment(emotion: positiveEmotions[2], date: Date(), description: "", image: "")],
                        20: [Moment(emotion: positiveEmotions[2], date: Date(), description: "", image: ""),
                             Moment(emotion: positiveEmotions[3], date: Date(), description: "", image: "")]])
        
        // 감정 기록된 일자
        recoredDays = moments.map { $0.keys.sorted() }
        
        // 감정별 개수
        emotions = moments.map {
            let emotionCount: [Emotion: Int] = $0.reduce(into: [:]) { emotions, momentsOfDay in
                _ = momentsOfDay.value.map { emotions[$0.emotion, default: 0] += 1 }
            }
            return emotionCount
        }
        
        monthString = date.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "%MM월"
            return formatter.string(from: $0)
        }
    }
}
