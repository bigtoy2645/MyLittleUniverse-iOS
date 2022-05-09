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
    let moments = BehaviorRelay<[Moment]>(value: [])
    let recordedDays = BehaviorRelay<Set<Int>>(value: [])
    let recordedEmotions = BehaviorRelay<Set<Emotion>>(value: [])
    let mainEmotion = BehaviorRelay<Emotion>(value: Emotion.empty)
    let selectedDay: BehaviorRelay<Int>
    let selectedMoments = BehaviorRelay<[Moment]>(value: [])
    
    let monthString: Observable<String>
    let rankings: Observable<[EmotionCount]>
    let ranking0: Observable<EmotionCount>
    let ranking1: Observable<EmotionCount?>
    let ranking2: Observable<EmotionCount?>
    let ranking3: Observable<EmotionCount?>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let date = Date()
        
        // 이달의 감정 목록
        Repository.instance.moments
            .map { $0.filter { $0.year == $0.year && $0.month == date.month } }
            .subscribe(onNext: moments.accept(_:))
            .disposed(by: disposeBag)
        
        // 기록된 날짜
        moments
            .map { Set($0.map { $0.day }) }
            .subscribe(onNext: self.recordedDays.accept(_:))
            .disposed(by: disposeBag)
        
        // 기록된 감정
        moments
            .map { Set($0.map { $0.emotion }) }
            .subscribe(onNext: self.recordedEmotions.accept(_:))
            .disposed(by: disposeBag)
        
        // 감정별 개수
        rankings = moments.map { moments in
            var ranking: [EmotionCount] = []
            for moment in moments {
                if ranking.contains(where: { $0.emotion == moment.emotion }) { continue }
                let count = moments.filter { $0.emotion == moment.emotion }.count
                let item = EmotionCount(emotion: moment.emotion, count: count)
                ranking.append(item)
            }
            return ranking.sorted { $0.count > $1.count }
        }
        
        ranking0 = rankings.map { $0[0] }
        ranking1 = rankings.map { $0.count <= 1 ? nil : $0[1] }
        ranking2 = rankings.map { $0.count <= 2 ? nil : $0[2] }
        ranking3 = rankings.map { $0.count <= 3 ? nil : $0[3] }
        
        monthString = Observable.of("\(date.month)월")
        
        // 메인 감정
        ranking0.map { $0.emotion }
            .subscribe(onNext: mainEmotion.accept(_:))
            .disposed(by: disposeBag)
        
        // 선택 날짜
        let defaultDay = recordedDays.value.max() ?? 1 - 0
        selectedDay = BehaviorRelay(value: defaultDay)
        
        // 선택한 날짜의 감정
        selectedDay
            .map { day in self.moments.value.filter { $0.day == day } }
            .subscribe(onNext: selectedMoments.accept(_:))
            .disposed(by: disposeBag)
    }
}
