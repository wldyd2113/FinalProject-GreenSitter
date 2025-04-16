//
//  LeavePlantListViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 4/16/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class LeavePlantListViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    @Published var post: [Post] = []
    //MARK: - Post데이터 가져오기
    func fetchPostFirebase() {
        // 현재 로그인된 사용자의 userId 가져오기
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        // Firestore에서 특정 문서 가져오기
        db.collection("posts").whereField("userId", isEqualTo: userId).whereField("postType", isEqualTo: "새싹돌봄이 찾습니다").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            // 문서가 존재하는지 확인
            for document in documents {
                let postData = document.data()
                
                print("Raw postData: \(postData)")
                let postId = postData["id"] as? String ?? "id없음"
                let postStatus = PostStatus(rawValue: postData["postStatus"] as? String ?? "") ?? .completedTrade
                let postTitle = postData["postTitle"] as? String ?? "제목 없음"
                let postBody = postData["postBody"] as? String ?? "본문 내용 없음"
                let updateDateTimestamp = postData["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                let updateDate = updateDateTimestamp.dateValue()
                let postImages = postData["postImages"] as? [String] ?? []
                
                // 데이터가 올바르게 불러와졌는지 출력해보기
                print("Post Id: \(postId), Post Title: \(postTitle), Post Body: \(postBody), Update Date: \(updateDate), Post Images: \(postImages)")

                
                // Post 객체 생성 및 배열에 추가
                let post = Post(
                    id: document.documentID,
                    enabled: true,
                    createDate: Date(),
                    updateDate: updateDate,
                    recipientId: "",
                    userId: userId,
                    profileImage: "",  // 필요시 추가
                    nickname: "",      // 필요시 추가
                    userLocation: Location.seoulLocation, // 예시 위치
                    userNotification: false, userLevel: .fruit,
                    postType: .lookingForSitter,
                    postTitle: postTitle,
                    postBody: postBody,
                    postImages: postImages,
                    postStatus: postStatus,
                    location: nil
                )
                
                // Post 배열에 추가
                self.post.append(post)
            }
        }
    }
    
    //MARK: - 이미지 스토리지에서 이미지 파일 불러오기
    func loadImage(from gsURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: gsURL) else {
            print("Invalid URL string: \(gsURL)")
            completion(nil)
            return
        }
        
        print("Fetching image from URL: \(url)") // URL 디버깅
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 응답의 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // 데이터 크기 및 내용 확인
            print("Image data size: \(data.count) bytes")
            
            // 데이터의 일부를 문자열로 변환하여 출력 (디버깅 용도)
            if let dataString = String(data: data, encoding: .utf8) {
                print("Data received: \(dataString.prefix(1000))") // 첫 1000바이트만 출력
            } else {
                print("Data is not a valid UTF-8 string")
            }
            
            // UIImage 객체 생성 시도
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data")
                completion(nil)
                return
            }
            
            completion(image)
        }
        task.resume()
    }

}

