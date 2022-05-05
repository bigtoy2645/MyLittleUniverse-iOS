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
    var description: String = ""
    var imageData: Data
    var bgColor: Int = 0xFFECC7
}

extension Moment {
    static let empty = Moment(emotion: Emotion.empty, date: Date(), imageData: Data())
}

var allMoments: [Moment] = []
