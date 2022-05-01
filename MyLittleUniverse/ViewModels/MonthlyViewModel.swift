//
//  MonthlyViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/19.
//

import Foundation
import RxSwift
import RxCocoa

struct EmotionCount {
    let emotion: Emotion
    let count: Int
}

class MonthlyViewModel {
    let recoredDays = BehaviorRelay<[Int]>(value: [])
    let mainEmotion = BehaviorRelay<Emotion>(value: Emotion.empty)
    let selectedDay: BehaviorRelay<Int>
    let selectedMoments = BehaviorRelay<[Moment]>(value: [])
    
    let monthString: Observable<String>
    let rankings: Observable<[Emotion: Int]>
    let ranking0: Observable<EmotionCount>
    let ranking1: Observable<EmotionCount?>
    let ranking2: Observable<EmotionCount?>
    let ranking3: Observable<EmotionCount?>
    private let sortedRankings: Observable<[Dictionary<Emotion, Int>.Element]>
    
    let disposeBag = DisposeBag()
    
    init(date: Date) {
        let date = Observable.just(date)
        let moments = BehaviorRelay<[Int: [Moment]]>(value: [:])
        
        // TODO - date 해당하는 데이터 불러오기
        moments.accept([1: [Moment(emotion: positiveEmotions[0], date: Date(), description: "", image: "Sample")],
                        4: [Moment(emotion: positiveEmotions[0], date: Date(), description: "", image: "Sample"),
                            Moment(emotion: positiveEmotions[1], date: Date(), description: "", image: "Sample")],
                        10: [Moment(emotion: positiveEmotions[1], date: Date(), description: "", image: "Sample"),
                             Moment(emotion: positiveEmotions[2], date: Date(), description: "", image: "Sample"),
                             Moment(emotion: positiveEmotions[3], date: Date(), description: "", image: "Sample")],
                        20: [Moment(emotion: positiveEmotions[2], date: Date(), description: "", image: "Sample"),
                             Moment(emotion: positiveEmotions[3], date: Date(), description: "", image: "Sample"),
                             Moment(emotion: positiveEmotions[4], date: Date(), description: "", image: "Sample"),
                             Moment(emotion: positiveEmotions[5], date: Date(), description: "", image: "Sample"),
                             Moment(emotion: positiveEmotions[6], date: Date(), description: "", image: "Sample")]
        ])
        
        // 감정 기록된 일자
        moments.map { $0.keys.sorted() }
            .subscribe(onNext: self.recoredDays.accept(_:))
            .disposed(by: disposeBag)
        
        // 감정별 개수
        rankings = moments.map { moments in
            let emotionCount: [Emotion: Int] = moments.reduce(into: [:]) { emotions, momentsOfDay in
                _ = momentsOfDay.value.map { emotions[$0.emotion, default: 0] += 1 }
            }
            return emotionCount
        }
        
        sortedRankings = rankings.map { $0.sorted { $0.1 > $1.1 } }
        
        ranking0 = sortedRankings.map { ranking in
            return EmotionCount(emotion: ranking[0].key, count: ranking[0].value)
        }
        
        ranking1 = sortedRankings.map { ranking in
            if ranking.count <= 1 { return nil }
            return EmotionCount(emotion: ranking[1].key, count: ranking[1].value)
        }
        
        ranking2 = sortedRankings.map { ranking in
            if ranking.count <= 2 { return nil }
            return EmotionCount(emotion: ranking[2].key, count: ranking[2].value)
        }
        
        ranking3 = sortedRankings.map { ranking in
            if ranking.count <= 3 { return nil }
            return EmotionCount(emotion: ranking[3].key, count: ranking[3].value)
        }
        
        monthString = date.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "%MM월"
            return formatter.string(from: $0)
        }
        
        ranking0.map { $0.emotion }
            .subscribe(onNext: mainEmotion.accept(_:))
            .disposed(by: disposeBag)
        
        selectedDay = BehaviorRelay(value: Array(moments.value.keys).sorted()[0] - 1)
        
        // 선택한 날짜의 감정
        selectedDay
            .map { selectedDay in
                guard let selectedMoments = moments.value[selectedDay + 1] else {
                    return []
                }
                return selectedMoments
            }
            .subscribe(onNext: selectedMoments.accept(_:))
            .disposed(by: disposeBag)
    }
}
