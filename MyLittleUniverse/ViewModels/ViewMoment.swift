//
//  ViewMoment.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/19.
//

import Foundation

struct ViewMoment {
    var status: String
    var date: String
    var description: String
    var image: String

    init(_ item: Moment) {
        status = item.status.rawValue
        description = item.description
        image = item.image
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM.dd"
        date = formatter.string(from: item.date)
    }
}
