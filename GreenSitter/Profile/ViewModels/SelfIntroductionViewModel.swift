////
////  SelfIntroductionViewModel.swift
////  GreenSitter
////
////  Created by 차지용 on 8/18/24.
////
//
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//extension SelfIntroductionViewController {
//    
//    //MARK: - 취소
//    @objc func closeButtonTap() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    //MARK: - 완료
//    @objc func completeButtonTap() {
//        guard let aboutMe = introductionTextView.text, !aboutMe.isEmpty else { return }
//        let userData: [String: Any] = [
//            "aboutMe": aboutMe
//        ]
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User ID is not available")
//            return
//        }
//        db.collection("users").document(userId).setData(userData, merge: true) { error  in
//            if let error = error {
//                print("Firestore Writing Error: \(error)")
//            }
//            else {
//                print("자기소개 successfully saved!")
//                
//                // 데이터가 성공적으로 저장되었음을 알림
//                NotificationCenter.default.post(name: NSNotification.Name("UserAboutMeUpdated"), object: nil)
//            }
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    
//    //MARK: - 파이어베이스 데이터 불러오기
//    func fetchUserFirebase() {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User ID is not available")
//            return
//        }
//        db.collection("users").document(userId).getDocument{[weak self] (document, error) in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("db 불러오기 오류 \(error)")
//                return
//            }
//            
//            if let document = document, document.exists, let data = document.data() {
//                DispatchQueue.main.async {
//                    if let aboutme = data["aboutMe"] as? String {
//                        self.introductionTextView.text = aboutme
//                        print("자기소개: \(aboutme)")
//                    }
//                    else {
//                        print("자기소개 데이터 찾을 수 없음")
//                    }
//                }
//            }
//            else {
//                print("문서 존재하지 않음")
//            }
//        }
//    }
//}
