//
//  NicknameViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 4/6/25.
//
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
//

class NicknameViewModel: ObservableObject {
    //MARK: - 닫기 버튼 Method
    @objc func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 닉네임 변경 메소드
    @objc func completeButtonTap() {
        guard let nickname = nicknameTextfield.text, !nickname.isEmpty else { return }
        
        // 닉네임 중복 검사
        db.collection("users").whereField("nickname", isEqualTo: nickname).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error checking nickname: \(error)")
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // 닉네임이 이미 사용 중일 때
                DispatchQueue.main.async {
                    self.nicknameStatusLabel.text = "이미 사용 중인 닉네임입니다."
                    self.nicknameStatusLabel.textColor = .red
                }
            } else {
                // 닉네임이 사용 가능할 때
                DispatchQueue.main.async {
                    self.nicknameStatusLabel.text = "사용 가능한 닉네임입니다."
                    self.nicknameStatusLabel.textColor = .green
                    self.updateNickname(nickname)
                    NotificationCenter.default.post(name: Notification.Name("NicknameChanged"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    
    //MARK: - 변경된 닉네임을 파이어베이스에 저장
    func updateNickname(_ nickname: String) {
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }

        let userId = user.uid
        let userData: [String: Any] = ["nickname": nickname]
        
        // 유저 컬렉션에 닉네임 업데이트
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                print("User Nickname successfully saved!")
                
                // 유저의 id를 통해 posts 컬렉션 조회
                self.db.collection("users").document(user.uid).getDocument { [weak self] document, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching user document: \(error)")
                        return
                    }
                    
                    if let document = document, document.exists {
                        if let postId = document.data()?["id"] as? String {
                            // 해당 id를 사용해 posts 컬렉션 업데이트
                            self.updatePostsNickname(postId, nickname)
                        }
                        
                    }
                }
            }
        }
    }
    
    //MARK: - post에 업데이트된 닉네임 저장
    func updatePostsNickname(_ postId: String, _ nickname: String) {
        guard let currentId = Auth.auth().currentUser?.uid else {
            print("유저 정보 없음")
            return
        }
        db.collection("posts").whereField("userId", isEqualTo: postId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in posts collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["nickname": nickname]) { error in
                    if let error = error {
                        print("Error updating post nickname in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("Post Nickname successfully updated in document \(document.documentID)!")
                    }
                }
            }
            self.updateChatUserNickname(currentId, nickname)
            self.updateChatPostNickname(currentId, nickname)

        }
    }
    //MARK: - 채팅에 업데이트된 유저닉네임 저장
    func updateChatUserNickname(_ currentId: String, _ nickname: String) {
        guard let currentId = Auth.auth().currentUser?.uid else {
            print("유저 정보 없음")
            return
        }
        db.collection("chatRooms").whereField("userId", isEqualTo: currentId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in chat collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in chat collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["userNickname": nickname]) { error in
                    if let error = error {
                        print("Error updating post nickname in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("updateChatNickname Nickname successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }
    
    //MARK: - 채팅에 업데이트된 post닉네임 저장
    func updateChatPostNickname(_ currentId: String, _ nickname: String) {
        guard let currentId = Auth.auth().currentUser?.uid else {
            print("유저 정보 없음")
            return
        }
        db.collection("chatRooms").whereField("postUserId", isEqualTo: currentId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in chat collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in chat collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["postUserNickname": nickname]) { error in
                    if let error = error {
                        print("Error updating post nickname in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("updateChatNickname Nickname successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }

    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                print("Document data: \(data)") // Firestore에서 가져온 데이터 출력
                DispatchQueue.main.async {
                    if let nickname = data["nickname"] as? String {
                        self.nicknameTextfield.placeholder = nickname
                        print("Nickname in UITextField: \(nickname)") // 닉네임 출력
                    } else {
                        print("No nickname found in data")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
