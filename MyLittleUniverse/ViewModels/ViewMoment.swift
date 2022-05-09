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
    let text: String
    let image: UIImage?

    init(_ item: Moment) {
        emotion = item.emotion.word
        text = item.text
        image = UIImage(data: item.imageData)
        date = "\(item.year).\(item.month).\(item.day)"
    }
}
