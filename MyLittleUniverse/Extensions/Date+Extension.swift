//
//  Date+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/07.
//

import Foundation

extension Date {
    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    public var month: Int {
         return Calendar.current.component(.month, from: self)
    }
    
    public var day: Int {
         return Calendar.current.component(.day, from: self)
    }
}
