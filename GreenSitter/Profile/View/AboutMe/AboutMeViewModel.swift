//
//  AboutMeViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 4/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

class AboutMeViewModel: ObservableObject {
    @Published var user: User?
    @Published var profileImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldPresentEditView: Bool = false
    @Published var locationAddress: String = ""
    @Published var nickname: String = "닉네임 없음"
    @Published var levelPoint: String = ""
    @Published var aboutMe: String = "자기 소개를 입력해주세요"
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    
    //MARK: - 자기소개 수정하기
    @objc func editButtonTapped() {
        shouldPresentEditView = true
    }
    
    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            print("userId: \(userId)")
            print("Auth UserId: \(String(describing: Auth.auth().currentUser?.uid))")
            if let document = document, document.exists {
                let data = document.data()
                let id = data?["id"] as? String ?? ""
                let enabled = data?["enable"] as? Bool
                let createDate = data?["createDate"] as? Date
                let updateDate = data?["updateDate"] as? Date
                let profileImage = data?["profileImage"] as? String ?? ""
                let nickname = data?["nickname"] as? String ?? "닉네임 없음"
                let platform = data?["platform"] as? String ?? ""
                let levelPoint = data?["levelPoint"] as? String ?? ""
                let exp = data?["exp"] as? Int
                let aboutMe = data?["aboutMe"] as? String ?? "자기 소개를 입력해주세요"
                let chatNotification = data?["chatNotification"] as? Bool
                
                print("Fetched levelPoint: \(levelPoint)")
                print("자기소개: \(aboutMe)")
                
                // location 필드에서 address를 가져오기
                if let location = data?["location"] as? [String: Any],
                   let locationAddress = location["address"] as? String {
                    self.user?.location.address = locationAddress
                    
                    // UI 업데이트: locationLabel에 주소 표시
                    DispatchQueue.main.async {
                        self.locationAddress = locationAddress
                    }
                } else {
                    // location 정보가 없을 때 기본값 설정
                    self.locationAddress = "주소 없음"
                }
                // 프로필 이미지 로드
                if !profileImage.isEmpty {
                    self.loadProfileImage(from: profileImage)
                }
                self.user = User(id: id, enabled: false, createDate: createDate ?? Date(), updateDate: updateDate ?? Date(), profileImage: profileImage, nickname: nickname, location: Location.sampleLocation, platform: platform, levelPoint: Level.flower, exp: 0, aboutMe: aboutMe, chatNotification: false)
                
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.nickname = nickname
                    self.levelPoint = levelPoint
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    //MARK: - 이미지 스토리지에서 이미지 파일 불러오기
    func loadProfileImage(from urlString: String) {
        var imageUrlString = urlString
        
        // 만약 URL이 gs:// 형식이라면 https:// 형식으로 변환
        if urlString.starts(with: "gs://") {
            imageUrlString = convertToHttpsURL(gsURL: urlString) ?? ""
        }
        
        guard let url = URL(string: imageUrlString) else {
            print("Invalid URL string: \(imageUrlString)")
            return
        }
        
        print("Fetching image from URL: \(url)") // URL을 로그로 출력하여 확인
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("이미지 다운로드 오류: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            print("Data received with size: \(data.count) bytes")
            
            guard let image = UIImage(data: data) else {
                print("error: 이미지로 변환 실패")
                return
            }
            
            DispatchQueue.main.async {
                self.profileImage = image
            }
        }
        task.resume()
    }
    
    //MARK: - gs:// URL을 https:// URL로 변환
    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) // 한 번만 호출
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }
}
