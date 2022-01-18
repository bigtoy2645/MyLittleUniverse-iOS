//
//  MomentViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import Foundation
import RxSwift

class MomentViewModel {
    let allMoments: Observable<[ViewMoment]>
    let numberOfDaysText: Observable<String>
    
    let disposeBag = DisposeBag()
    
    init() {
        // TODO - 데이터 불러오기
        let moments = BehaviorSubject<[Moment]>(value: [Moment(status: .glad, date: Date(), description: "glad1", image: ""),
                                                        Moment(status: .funny, date: Date(), description: "funny1", image: ""),
                                                        Moment(status: .funny, date: Date(), description: "funny2", image: "")])
        
        allMoments = moments.map { $0.map { ViewMoment($0) } }
        numberOfDaysText = moments.map { "for \($0.count) days" }
    }
}
