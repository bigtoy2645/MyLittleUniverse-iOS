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
    let selectedIndex: BehaviorRelay<Int>
    let selectedMoments = BehaviorRelay<[Moment]>(value: [])
    let rankings = BehaviorRelay<[EmotionCount]>(value: [])
    
    let monthString: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let date = Date()
        
        // 이달의 감정 목록
        Repository.instance.moments
            .map { $0.filter { ($0.year == date.year) && ($0.month == date.month) } }
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
        moments
            .map { moments -> [EmotionCount] in
                var ranking: [EmotionCount] = []
                for moment in moments {
                    if ranking.contains(where: { $0.emotion == moment.emotion }) { continue }
                    let count = moments.filter { $0.emotion == moment.emotion }.count
                    let item = EmotionCount(emotion: moment.emotion, count: count)
                    ranking.append(item)
                }
                return ranking.sorted { $0.count > $1.count }
            }
            .subscribe(onNext: rankings.accept(_:))
            .disposed(by: disposeBag)
        
        monthString = Observable.of("\(date.month)월")
        
        // 메인 감정
        rankings.map { $0[safe: 0]?.emotion ?? .empty }
            .subscribe(onNext: mainEmotion.accept(_:))
            .disposed(by: disposeBag)
        
        // 선택 날짜
        selectedIndex = BehaviorRelay(value: date.day - 1)
        
        // 선택한 날짜의 감정
        selectedIndex
            .map { index in
                let filtered = self.moments.value.filter { $0.day == index + 1 }
                return filtered
            }
            .subscribe(onNext: selectedMoments.accept(_:))
            .disposed(by: disposeBag)
        
        // 이달의 감정 변경 시 감정 카드 업데이트
        moments
            .bind { _ in
                self.selectedIndex.accept(self.selectedIndex.value)
            }
            .disposed(by: disposeBag)
    }
}
