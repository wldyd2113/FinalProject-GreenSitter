//
//  SelfIntroductionViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 4/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class SelfIntroductionViewModel: ObservableObject {
    @Published var aboutMe: String = ""
    private let db = Firestore.firestore()

    //MARK: - 완료
    @objc func completeButtonTap(completion: @escaping(Bool) -> Void) {
        guard !aboutMe.isEmpty else {
            completion(false)
            return }
        let userData: [String: Any] = [
            "aboutMe": aboutMe
        ]
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        db.collection("users").document(userId).setData(userData, merge: true) { error  in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            }
            else {
                print("자기소개 successfully saved!")
                
                // 데이터가 성공적으로 저장되었음을 알림
                NotificationCenter.default.post(name: NSNotification.Name("UserAboutMeUpdated"), object: nil)
                completion(true)
            }
        }
    }

    
    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase(compeltion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            compeltion(nil)
            return
        }
        db.collection("users").document(userId).getDocument{[weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("db 불러오기 오류 \(error)")
                compeltion(nil)
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    if let aboutme = data["aboutMe"] as? String {
                        self.aboutMe = aboutme
                        print("자기소개: \(aboutme)")
                        compeltion(aboutme)
                    }
                    else {
                        print("자기소개 데이터 찾을 수 없음")
                        compeltion(nil)
                    }
                }
            }
            else {
                print("문서 존재하지 않음")
            }
        }
    }
    
}
