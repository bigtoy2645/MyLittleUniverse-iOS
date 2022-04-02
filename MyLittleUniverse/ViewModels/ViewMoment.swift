//
//  ViewMoment.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/19.
//

import Foundation

struct ViewMoment {
    let emotion: String
    let date: String
    let description: String
    let image: String

    init(_ item: Moment) {
        emotion = item.emotion.rawValue
        description = item.description
        image = item.image
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM.dd"
        date = formatter.string(from: item.date)
    }
}
