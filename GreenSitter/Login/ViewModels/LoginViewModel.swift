//
//  LoginViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/14/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class LoginViewModel: ObservableObject {
    static let shared = LoginViewModel()
    
    @Published var user: User?
    @Published var profileImage: UIImage?
    
    let db = Firestore.firestore()
    
//    private init() {}

    func firebaseFetch(docId: String, completion: @escaping () -> Void) {
        db.collection("users").document(docId).getDocument { (document, error) in
            if let error = error {
                print("데이터 불러오기 실패: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else {
                print("문서가 존재하지 않습니다.")
                return
            }

            let data = document.data()
            let id = data?["id"] as? String ?? docId
            let enabled = data?["enabled"] as? Bool ?? false
            let createDate = (data?["createDate"] as? Timestamp)?.dateValue() ?? Date()
            let updateDate = (data?["updateDate"] as? Timestamp)?.dateValue() ?? Date()
            let profileImage = data?["profileImage"] as? String ?? ""
            let nickname = data?["nickname"] as? String ?? "닉네임 없음"
            let platform = data?["platform"] as? String ?? ""
            let levelPoint = data?["levelPoint"] as? String ?? ""
            let exp = data?["exp"] as? Int ?? 0
            let aboutMe = data?["aboutMe"] as? String ?? ""
            let chatNotification = data?["chatNotification"] as? Bool ?? false

            // Location 데이터 변환
            var location: Location?
            if let locationData = data?["location"] as? [String: Any] {
                // 위치 정보 문자열을 Double로 변환
                let latitude = locationData["latitude"] as? Double ?? 37.566 // 기본값 설정
                let longitude = locationData["longitude"] as? Double ?? 126.97 // 기본값 설정

                let locationId = locationData["locationId"] as? String ?? ""
                let enabled = (locationData["enabled"] as? Bool) ?? false
                let placeName = locationData["placeName"] as? String ?? ""
                let address = locationData["address"] as? String ?? ""
                
                // Firestore에서 가져온 createDate 및 updateDate는 문자열로 되어 있으므로 Date로 변환
                let dateFormatter = ISO8601DateFormatter()
                let createDateString = locationData["createDate"] as? String ?? ""
                let updateDateString = locationData["updateDate"] as? String ?? ""
                let createDate = dateFormatter.date(from: createDateString) ?? Date()
                let updateDate = dateFormatter.date(from: updateDateString) ?? Date()

                location = Location(locationId: locationId, enabled: enabled, createDate: createDate, updateDate: updateDate, latitude: latitude, longitude: longitude, placeName: placeName, address: address)
            } else {
                print("위치정보 없음")
            }
            DispatchQueue.main.async {
                self.user = User(id: id,
                                 enabled: enabled,
                                 createDate: createDate,
                                 updateDate: updateDate,
                                 profileImage: profileImage,
                                 nickname: nickname,
                                 location: location ?? Location.seoulLocation,
                                 platform: platform,
                                 levelPoint: Level(rawValue: levelPoint) ?? .fruit,
                                 exp: exp,
                                 aboutMe: aboutMe,
                                 chatNotification: chatNotification)
                print("사용자 데이터 불러오기: \(String(describing: self.user))")
                completion()
            }
            
        }
    }
    
    func loadProfileImage(from gsURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let httpsURLString = convertToHttpsURL(gsURL: gsURL),
              let url = URL(string: httpsURLString) else {
            print("Invalid URL string: \(gsURL)")
            completion(nil)
            return
        }
        
        print("Fetching image from URL: \(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download error: \(error)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("No data received or failed to convert data to UIImage")
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }


    func convertToHttpsURL(gsURL: String) -> String? {
        // 이미 HTTPS URL인지 확인
        if gsURL.starts(with: "https://") {
            print("이미 변환된 HTTPS URL: \(gsURL)")
            return gsURL
        }
        
        // gs:// URL을 https:// URL로 변환
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }


    func updateUserLocation(with location: Location) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        
        let userLocationData: [String: Any] = [
            "location": location.toDictionary(),
        ]
        db.collection("users").document(userId).setData(userLocationData, merge: true) { error in
            if let error = error {
                print("Failed to update user location: \(error.localizedDescription)")
            }
            else {
                print("User location updated successfully with address: \(location)")
            }
        }
        self.user?.location = location
        print("Attempting to update user location with address: \(location)")
    }
    
}

