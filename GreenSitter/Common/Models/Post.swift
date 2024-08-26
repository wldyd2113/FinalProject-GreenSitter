//
//  Post.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    
    // user
    let userId: String
    let profileImage: String
    let nickname: String
    let userLocation: Location
    let userNotification: Bool
    
    let postType: PostType
    let postTitle: String
    let postBody: String
    let postImages: [String]?
    let postStatus: PostStatus
    let location: Location?
}

enum PostType: String, Codable {
    case lookingForSitter = "새싹돌봄이 찾습니다"
    case offeringToSitter = "새싹 돌봐드립니다"
}

enum PostStatus: String, Codable {
    case beforeTrade = "거래전"
    case inTrade = "거래중"
    case completedTrade = "거래완료"
}


