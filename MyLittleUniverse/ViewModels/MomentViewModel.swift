//
//  MomentViewModel.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import Foundation
import RxSwift

class MomentViewModel {
    let allMoments: Observable<[Moment]>
    let numberOfDaysText: Observable<String>
    
    let disposeBag = DisposeBag()
    
    init() {
        let moments = BehaviorSubject<[Moment]>(value: [Moment(status: .glad, date: Date(), description: "glad1", image: ""),
                                                        Moment(status: .funny, date: Date(), description: "funny1", image: ""),
                                                        Moment(status: .funny, date: Date(), description: "funny2", image: "")])
        
        allMoments = moments
        numberOfDaysText = moments.map { "for \($0.count) days" }
    }
}
