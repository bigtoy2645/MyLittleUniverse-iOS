//
//  Status.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import Foundation

struct Moment {
    var emotion: Emotion
    var date: Date
    var description: String
    var image: String
}

extension Moment {
    static let empty = Moment(emotion: positiveEmotions[0], date: Date(), description: "desc", image: "")
}
