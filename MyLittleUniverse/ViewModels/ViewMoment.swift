//
//  ViewMoment.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/19.
//

import Foundation
import UIKit

struct ViewMoment {
    let emotion: String
    let date: String
    let description: String
    let image: UIImage?

    init(_ item: Moment) {
        emotion = item.emotion.word
        description = item.description
        image = UIImage(data: item.imageData)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM.dd"
        date = formatter.string(from: item.date)
    }
}
