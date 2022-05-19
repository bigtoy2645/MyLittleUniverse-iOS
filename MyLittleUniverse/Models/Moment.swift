//
//  Status.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import Foundation

struct Moment: Codable {
    var year: Int = Date().year
    var month: Int = Date().month
    var day: Int = Date().day
    var timeStamp: TimeInterval = Date().timeIntervalSinceReferenceDate
    var emotion: Emotion
    var text: String = ""
    var textColor: Int = 0x000000
    var imageData: Data
    var bgColor: Int = 0xFFECC7
}

extension Moment: Equatable {
    static let empty = Moment(emotion: Emotion.empty, imageData: Data())
    
    static func == (lhs: Moment, rhs: Moment) -> Bool {
        return (lhs.timeStamp == rhs.timeStamp && lhs.emotion == rhs.emotion)
    }
}
