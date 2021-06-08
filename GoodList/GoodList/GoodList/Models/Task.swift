//
//  Task.swift
//  GoodList
//
//  Created by Mdo on 07/06/2021.
//

import Foundation



enum Priority:Int{
    case high
    case medium
    case low
}
struct Task {
    let title:String
    let priority:Priority
}
