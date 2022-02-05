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

enum Emotion: String {
    case glad           = "기쁜"
    case exciting       = "신나는"
    case touching       = "감동적인"
    case satisfied      = "만족스러운"
    case joyful         = "즐거운"
    case pitapat        = "설레는"
    case comfortable    = "편안한"
    case forward        = "기대되는"
    case belazy         = "홀가분한"
    case lovely         = "사랑스러운"
    case proud          = "뿌듯한"
    case happy          = "행복한"
    case relaxed        = "여유로운"
    case funny          = "재미있는"
    case confident      = "자신있는"
}
