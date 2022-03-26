//
//  Sticker.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/01.
//

import Foundation
import UIKit

struct Sticker {
    var image: UIImage?
    var text: String?
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var hexColor: Int = 0xC4C4C4
}

extension Sticker: Equatable {
    static func == (lhs: Sticker, rhs: Sticker) -> Bool {
        return (lhs.image == rhs.image &&
                    lhs.text == rhs.text &&
                    lhs.hexColor == rhs.hexColor)
    }
}
