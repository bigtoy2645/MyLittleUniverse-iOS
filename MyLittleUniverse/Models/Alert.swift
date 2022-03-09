//
//  Alert.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/09.
//

import Foundation

struct Alert {
    let title: String
    var subtitle: String?
    var imageName: String?
    var runButtonTitle: String?
    var cancelButtonTitle: String?
}

extension Alert {
    static let empty = Alert(title: "")
}
