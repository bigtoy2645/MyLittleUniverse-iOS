//
//  MyPageViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/29.
//

import UIKit
import RxSwift
import RxCocoa

class MyPageViewModel {
    let moments = BehaviorRelay<[Moment]>(value: [])
    let currentPage = BehaviorRelay<Date>(value: Date())
    let selectedDate = BehaviorRelay<Date>(value: Date())
    let calendarDate = BehaviorRelay<String>(value: "")
    let userName: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init() {
        // 사용자명
        userName = Observable.of(Repository.instance.userName).map { "\($0)님" }
        
        // 이달의 감정 목록
        Repository.instance.moments
            .subscribe(onNext: moments.accept(_:))
            .disposed(by: disposeBag)
        
        currentPage.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY. MM"
            return formatter.string(from: $0)
        }
        .bind(to: calendarDate)
        .disposed(by: disposeBag)
    }
}
