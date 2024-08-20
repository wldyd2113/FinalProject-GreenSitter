//
//  LoginViewController.swift
//  GreenSitter
//
//  Created by Jiyong Cha on 8/7/24.
//
import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

class LoginViewController: UIViewController {
    var currentNonce: String? //Apple Login Property
    var users: User?
    let db = Firestore.firestore()
        
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새싹 돌봄이"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = """
    내 주변의 새싹 돌봄이 ☘️들이
    당신의 소중한 식물을
    돌봐드립니다
"""
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .labelsPrimary
        label.numberOfLines = 0 // 여러 줄 텍스트를 지원
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(appleLogin), for: .touchUpInside)
        return button
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleLogin"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        return button
    }()
    
    private var textButton: UIButton = {
        let button = UIButton()
        button.setTitle("둘러보기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(navigationTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .white
        
        view.addSubview(bodyLabel)
        view.addSubview(titleLabel)
        view.addSubview(appleButton)
        view.addSubview(googleButton)
        view.addSubview(textButton)
        
        showToast(withDuration: 1, delay: 4)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            bodyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -230),
            appleButton.widthAnchor.constraint(equalToConstant: 300),
            appleButton.heightAnchor.constraint(equalToConstant: 50),
            
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            googleButton.widthAnchor.constraint(equalToConstant: 300),
            googleButton.heightAnchor.constraint(equalToConstant: 50),
            
            textButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
        ])
        
    }
    
    //MARK: - ToastMessage
    func showToast(withDuration: Double, delay: Double) {
        let toastLabelWidth: CGFloat = 380
        let toastLabelHeight: CGFloat = 80
        
        // UIView 생성
        let toastView = UIView(frame: CGRect(x: (self.view.frame.size.width - toastLabelWidth) / 2, y: 75, width: toastLabelWidth, height: toastLabelHeight))
        toastView.backgroundColor = UIColor.white
        toastView.alpha = 1.0
        toastView.layer.cornerRadius = 25
        toastView.clipsToBounds = true
        toastView.layer.borderColor = UIColor.gray.cgColor
        toastView.layer.borderWidth = 1
        
        // 쉐도우 설정
        toastView.layer.shadowColor = UIColor.gray.cgColor
        toastView.layer.shadowOpacity = 0.5 // 투명도
        toastView.layer.shadowOffset = CGSize(width: 4, height: 4) // 그림자 위치
        toastView.layer.shadowRadius = 10
        
        // UIImageView 생성 및 설정
        let image = UIImageView(image: UIImage(named: "logo7"))
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true  // 이미지의 크기를 설정.
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // UILabel 생성 및 설정
        let labelOne = UILabel()
        labelOne.text = "로그인이 권한이 필요한 기능입니다"
        labelOne.textColor = .black
        labelOne.font = UIFont.systemFont(ofSize: 13)
        labelOne.textAlignment = .left
        labelOne.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTwo = UILabel()
        labelTwo.text = "로그인화면으로 이동합니다"
        labelTwo.textColor = .black
        labelTwo.font = UIFont.systemFont(ofSize: 11)
        labelTwo.textAlignment = .left
        labelTwo.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Vertical Stack)
        let labelStackView = UIStackView(arrangedSubviews: [labelOne, labelTwo])
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Horizontal Stack)
        let mainStackView = UIStackView(arrangedSubviews: [image, labelStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(mainStackView)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
            mainStackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10)
        ])
        
        self.view.addSubview(toastView)
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            toastView.removeFromSuperview()
        })
    }
    
    
    //MARK: - GoogleLogin
    @objc func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Unable to fetch clientID.")
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("Google SignIn Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                print("Error: GoogleSignIn result is nil.")
                return
            }
            
            guard let idToken = user.idToken?.tokenString else {
                print("Error: Unable to fetch idToken.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // Firebase 인증 처리
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase SignIn Error: \(error.localizedDescription)")
                    return
                }
                
                guard let user = authResult?.user else {
                    print("Error: Firebase authResult is nil.")
                    return
                }
                
                let post = Post(
                    id: UUID().uuidString,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: "exampleUserId",
                    profileImage: "exampleProfileImageURL",
                    nickname: "exampleNickname",
                    userLocation: Location.seoulLocation,
                    userNotification: false,
                    postType: .offeringToSitter,
                    postTitle: "exampleTitle",
                    postBody: "exampleBody",
                    postImages: ["exampleImage1", "exampleImage2"],
                    postStatus: .beforeTrade,
                    location: Location.seoulLocation
                )
                
                let userA = User(id: user.uid, enabled: true, createDate: Date(), updateDate: Date(), profileImage: "exampleImage1", nickname: "", location: Location.seoulLocation, platform: "", levelPoint: 1, aboutMe: "", chatNotification: true)

                // Firestore에 문서 저장
                let userRef = self.db.collection("users").document(user.uid)
                userRef.setData([
                    "user" : [
                        "id": user.uid,
                        "createDate": Timestamp(date: userA.createDate),
                        "updateDate": Timestamp(date: userA.updateDate),
                        "profileImage": userA.profileImage,
                        "nickname": userA.nickname,
                        "address": "서울특별시 구로구 온수동",
                        "aboutMe": userA.aboutMe
                    ],
                    "post":[
                    "id": post.id,
                    "enabled": post.enabled,
                    "createDate": Timestamp(date: post.createDate), // Date를 Timestamp로 변환
                    "updateDate": Timestamp(date: post.updateDate), // Date를 Timestamp로 변환
                    "userId": post.userId,
                    "profileImage": post.profileImage,
                    "nickname": post.nickname,
                    "userLocation": [
                        "latitude": post.userLocation.latitude,
                        "longitude": post.userLocation.longitude
                    ],
                    "userNotification": post.userNotification,
                    "postType": post.postType.rawValue,
                    "postTitle": post.postTitle,
                    "postBody": post.postBody,
                    "postImages": post.postImages ?? [],
                    "postStatus": post.postStatus.rawValue,
                    "location": post.location != nil ? [
                        "latitude": post.location?.latitude ?? 0,
                        "longitude": post.location?.longitude ?? 0
                    ] : NSNull() // 위치가 없을 경우 NSNull() 사용
                ],
                ]) { error in
                    if let error = error {
                        print("Firestore 저장 오류: \(error.localizedDescription)")
                    } else {
                        print("Firestore에 사용자 정보 저장 성공")
                    }
                }
                
                DispatchQueue.main.async {
                    // Ensure that self is in a UINavigationController
                    if let navigationController = self.navigationController {
                        let setLocationViewController = SetLocationViewController()
                        navigationController.pushViewController(setLocationViewController, animated: true)
                    } else {
                        print("Error: The current view controller is not embedded in a UINavigationController.")
                    }
                }
            }
        }
    }



    
    //MARK: - MainView move
    @objc func navigationTap() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0 // Home 탭으로 설정
        }
    }
}


//MARK: - AppleLogin
extension LoginViewController:ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    //Apple의 응답을 처리
    @objc func appleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Firebase에 사용자 인증 정보 저장
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: String(data: appleIDCredential.identityToken!, encoding: .utf8)!,
                                                      rawNonce: currentNonce!)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
                if (error != nil) {
                    //로그인 오류 처리
                    print("Apple 로그인 오류: \(error?.localizedDescription)")
                    return
                }
                //Firebase Database에 사용자 정보 저장
                if let user = authResult?.user {
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(user.uid)
                    
                    userRef.setData([
                        "uid": user.uid,
                        "email": user.email ?? "",
                        "displayName": user.displayName ?? "",
                        "location": users?.location ?? ""
                    ])
                }
                
                DispatchQueue.main.async {
                    // Ensure that self is in a UINavigationController
                    if let navigationController = self.navigationController {
                        let setLocationViewController = SetLocationViewController()
                        navigationController.pushViewController(setLocationViewController, animated: true)
                    } else {
                        print("Error: The current view controller is not embedded in a UINavigationController.")
                    }
                }
            }
        }
    }

    //로그인 실패 처리코드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 실패: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // 현재 뷰 컨트롤러의 윈도우를 반환
    }
    
    //로그인 요청 시 nonce값이 필요해서 주어진 길이의 난수 문자열을 생성하는 매서드
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    //주어진 문자열의 SHA256 해시 값을 반환하는 메서드
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

