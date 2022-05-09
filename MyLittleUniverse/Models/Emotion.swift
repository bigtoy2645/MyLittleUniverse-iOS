//
//  Emotion.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/04/27.
//

import Foundation

struct Emotion: Hashable, Codable {
    let word: String
    let origin: String
    let part: partSpeech
    let definition: String
}

extension Emotion {
    static let empty = Emotion(word: "N/A", origin: "N/A", part: .notAvailable, definition: "N/A")
}

enum partSpeech: String, Codable {
    case noun = "명"
    case verb = "동"
    case adjective = "형"
    case adverb = "관"
    case inverb = "자"
    case notAvailable = "?"
}
