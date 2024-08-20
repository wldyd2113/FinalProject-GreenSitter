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

extension User {
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Ensure the date format matches your Firestore settings
        if let data = try? encoder.encode(self) {
            return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
        }
        return [:]
    }
}
