//
//  ProfileViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 3/26/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Combine
import AuthenticationServices
import GoogleSignIn
class ProfileViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var user: User?
    @Published var profileImage: UIImage?
    @Published var levelImage: UIImage?
    @Published var isLoading = false
    @Published var alertMessage: String?

    
    private var currentReauthCompletion: ((Bool) -> Void)?
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    var logoutCompleted: (() -> Void)?


    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase(completion: @escaping () -> Void) {
        let loginViewModel = LoginViewModel.shared
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인된 사용자가 없습니다"
            return
        }
        
        loginViewModel.firebaseFetch(docId: currentUserID) {
            print("Firebase fetch completed.")
            completion()
        }
        
        if let profileImageURL = loginViewModel.user?.profileImage {
            loginViewModel.loadProfileImage(from: profileImageURL) { [weak self] image in
                guard let self = self else { return }
                self.profileImage = image
            }
        }

    }

    
    
    func updateNickname(_ profileImage: String) {
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        
        let userData: [String: Any] = ["profileImage": profileImage]
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                print("Nickname successfully saved!")
            }
        }
    }
        
    func fetchUserLevelAndUpdateImage(completion: @escaping (UIImage?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("로그인된 사용자가 없습니다.")
            return
        }

        db.collection("users").document(currentUserID).getDocument { [weak self] (document: DocumentSnapshot?, error: Error?) in
            guard let self = self else { return }
            
            if let error = error {
                print("Firestore 읽기 오류: \(error)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let levelString = data["levelPoint"] as? String,
                  let level = Level(rawValue: levelString) else {
                print("레벨 정보를 가져오는 중 오류 발생")
                return
            }
            
            // 레벨에 따른 이미지 URL을 가져옵니다.
            guard let imageURLString = self.imageURLForLevel(level) else {
                print("레벨에 맞는 이미지 URL을 생성할 수 없습니다.")
                return
            }
            
            print("Level image URL: \(imageURLString)")
            
            guard let httpsURLString = self.convertToHttpsURL(gsURL: imageURLString) else {
                print("https URL로 변환할 수 없습니다.")
                return
            }
            
            self.downloadImage(from: httpsURLString) { image in
                completion(image)
            }
        }
    }



    
    //MARK: - Level이미지 불러오기
    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let imageRef = storage.reference(forURL: url)
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Image download error: \(error)")
                completion(nil)
            } else if let data = data, let images = UIImage(data: data) {
                completion(images)
            }
        }
    }
    // 레벨에 따라 이미지 URL을 반환하는 함수
    func imageURLForLevel(_ level: Level) -> String? {
        let levelImageURLs: [String: String] = [
            "썩은 씨앗": "gs://greensitter-6dedd.appspot.com/level_image/썩은 씨앗2.png",
            "씨앗": "gs://greensitter-6dedd.appspot.com/level_image/씨앗3.png",
            "새싹": "gs://greensitter-6dedd.appspot.com/level_image/새싹.jpg",
            "유묘": "gs://greensitter-6dedd.appspot.com/level_image/유묘1.jpg",
            "꽃":"gs://greensitter-6dedd.appspot.com/level_image/꽃1.png",
            "열매": "gs://greensitter-6dedd.appspot.com/level_image/열매2.png" // 필요한 URL 추가
        ]
        
        return levelImageURLs[level.rawValue]
    }
    // MARK: - gs:// URL을 https:// URL로 변환
    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        
        // gs:// URL을 https:// URL로 변환하는 과정
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) // 특수문자 인코딩

        if encodedPath == nil {
            print("Error: URL 인코딩 실패 - \(gsURL)")
        } else {
            print("Success: URL 인코딩 성공 - \(encodedPath!)")
        }

        return baseURL + (encodedPath ?? "") + "?alt=media"
    }


    
    // MARK: - 이미지 파일 스토리지에서 이미지 파일 불러오기
    func loadProfileImage(from gsURL: String) {
        // 1. gsURL을 httpsURL로 변환
        guard let httpsURLString = convertToHttpsURL(gsURL: gsURL),
              let url = URL(string: httpsURLString) else {
            print("Error: Invalid URL string after conversion: \(gsURL)")
            return
        }
        
        print("Fetching image from URL: \(url)")

        // 2. URLSession을 사용해 이미지 데이터를 다운로드
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                return
            }
            
            // 3. HTTP 응답 상태 코드 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode) - URL: \(url)")
                    if let responseURL = httpResponse.url {
                        print("Response URL: \(responseURL)")
                    }
                    if let fields = httpResponse.allHeaderFields as? [String: Any] {
                        print("HTTP Response Headers: \(fields)")
                    }
                    return
                }
            }
            
            // 4. 데이터 수신 확인
            guard let data = data, let image = UIImage(data: data) else {
                print("No data received or failed to convert data to UIImage - URL: \(url)")
                return
            }
            
            // 5. 이미지가 성공적으로 로드된 경우, UI 업데이트
            DispatchQueue.main.async {
                self.profileImage = image
            }
        }
        task.resume()
    }

    
    
    
    //MARK: - 이미지 파일 스토리지 업로드
    func uploadImage(image: UIImage, completion: @escaping(String?) -> Void) {
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error: Unable to convert UIImage to Data")
            completion(nil)
            return
        }
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Firebase Storage Error: \(error)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                } else {
                    if let urlString = url?.absoluteString {
                        print("Uploaded image URL: \(urlString)") // URL을 로그로 출력
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
    

    
    
    //MARK: - 로그아웃
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.logoutCompleted?()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    //MARK: - 구글 재인증
    func reauthenticateWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            completion(false)
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                print("Google sign-in error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let authentication = signInResult?.user else {
                print("Google authentication failed.")
                completion(false)
                return
            }
            
            guard let idToken = authentication.idToken?.tokenString else {
                print("Failed to retrieve ID token.")
                completion(false)
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)

            currentUser.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Re-authentication with Google failed: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Re-authentication with Google succeeded.")
                    completion(true)
                }
            }
        }
    }

    
    //MARK: - Apple재인증
    func reauthenticateWithApple(completion: @escaping (Bool) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(false)
                return
            }

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            
            // completion 클로저를 저장합니다.
            self.currentReauthCompletion = completion
            
            authorizationController.performRequests()
        }

        // ASAuthorizationControllerDelegate 메서드
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                print("Apple ID Credential 또는 identity token이 없습니다.")
                currentReauthCompletion?(false)
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: "")

            Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Apple로 재인증 실패: \(error.localizedDescription)")
                    self.currentReauthCompletion?(false)
                } else {
                    print("Apple로 재인증 성공.")
                    self.currentReauthCompletion?(true)
                }
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Apple 로그인 에러: \(error.localizedDescription)")
            currentReauthCompletion?(false)
        }

        // ASAuthorizationControllerPresentationContextProviding 메서드
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return UIApplication.shared.windows.first!
        }
    
    
    
    //MARK: - 회원 탈퇴
    func accountDeletion() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "회원탈퇴시, 모든 가입 정보가 삭제됩니다 \n 다시 로그인하려면 재가입이 필요합니다 \n\n 정말로 회원탈퇴를 진행하시겠습니까?", preferredStyle: .alert)
        let cancle = UIAlertAction(title: "취소", style: .cancel) {
            action in
            print("취소")
        }
        let deletion = UIAlertAction(title: "탈퇴 하기", style: .destructive){ action in
            print("탈퇴 눌렸습니다.")
            self.deleteUserAccount()
        }
        alert.addAction(cancle)
        alert.addAction(deletion)
        // 현재 활성화된 뷰 컨트롤러에 알림 표시
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        let providerData = user.providerData.first
        let providerID = providerData?.providerID
        
        let reauthenticate: (@escaping (Bool) -> Void) -> Void
        
        if providerID == "google.com" {
            reauthenticate = reauthenticateWithGoogle
        } else if providerID == "apple.com" {
            reauthenticate = reauthenticateWithApple
        } else {
            print("Unsupported provider: \(providerID ?? "unknown")")
            return
        }
        
        reauthenticate { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.deleteUserData { success in
                    if success {
                        user.delete { error in
                            if let error = error {
                                print("Error deleting user: \(error.localizedDescription)")
                            } else {
                                print("User account deleted successfully")
                                self.logoutCompleted?()
                            }
                        }
                    } else {
                        print("Failed to delete user data from Firestore")
                    }
                }
            } else {
                print("Re-authentication failed. Please try again.")
            }
        }
    }

    //MARK: - 채팅 및 Post내용 삭제
    func deleteUserData(completion: @escaping(Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // Firestore 참조 생성
        let db = Firestore.firestore()

        // 여러 삭제 작업을 수행하기 위해 배치를 시작
        let batch = db.batch()

        // 'users' 컬렉션에서 사용자의 문서 삭제
        let userDocRef = db.collection("users").document(userId)
        batch.deleteDocument(userDocRef)

        // 사용자가 작성한 모든 포스트 삭제
        let postsRef = db.collection("posts").whereField("userId", isEqualTo: userId)
        postsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("포스트를 가져오는 중 오류 발생: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(true) // 문서가 없으면 완료 처리
                return
            }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }

            // 사용자가 속한 모든 채팅방 삭제
            let chatRoomsRef = db.collection("chatRooms").whereField("userId", isEqualTo: userId)
            chatRoomsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("채팅방을 가져오는 중 오류 발생: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion(true) // 문서가 없으면 완료 처리
                    return
                }

                for document in documents {
                    batch.deleteDocument(document.reference)
                }

                // Firestore에 배치 커밋
                batch.commit { error in
                    if let error = error {
                        print("사용자 데이터 삭제 중 오류 발생: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Firestore에서 사용자 데이터가 성공적으로 삭제되었습니다.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    

}
