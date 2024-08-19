//
//  User.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct User: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let profileImage: String
    var nickname: String
    var location: Location
    let platform: String
    let levelPoint: Int
    let aboutMe: String
    let chatNotification: Bool
}

