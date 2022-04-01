//
//  Sticker.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/01.
//

import Foundation
import UIKit

struct Sticker {
    let type: StickerType
    var image: UIImage?
    var text: String?
    var hexColor: Int = 0xC4C4C4
}

enum StickerType {
    case picture
    case shape
    case text
}

extension Sticker: Equatable {
    static func == (lhs: Sticker, rhs: Sticker) -> Bool {
        return (lhs.type == rhs.type &&
                    lhs.image == rhs.image &&
                    lhs.text == rhs.text &&
                    lhs.hexColor == rhs.hexColor)
    }
}
