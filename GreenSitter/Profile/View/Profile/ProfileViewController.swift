//
//  ProfileViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Combine
import AuthenticationServices
import Photos

class ProfileViewController: UIViewController, LoginViewControllerDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func didCompleteLogin() {
        setupView()
        fetchUserFirebase()
        setupTextField()
        self.tableView.reloadData()
    }

    // MARK: - Properties
    var sectionTitle = ["내 정보", "돌봄 정보", "시스템", "이용약관 및 개인정보 처리방침" ]
    var textFieldContainer: UIView?
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let someIndexPath = IndexPath(row: 0, section: 0) // 적절한 인덱스 경로로 대체
    var currentReauthCompletion: ((Bool) -> Void)?
    
    let mapViewModel = MapViewModel()
    var cancellables = Set<AnyCancellable>()
    var profileTableView: UITableView!
    
    // MARK: - UI Components
    lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 60
        view.layer.masksToBounds = true
        
        // Progress layer
        let progressLayer = CAShapeLayer()
        progressLayer.strokeColor = UIColor(named: "DominentColor")?.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 60, y: 60), radius: 60, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        progressLayer.path = circularPath.cgPath
        view.layer.addSublayer(progressLayer)
        
        view.backgroundColor = UIColor(named: "SeparatorsOpaque")
        
        return view
    }()
    
    lazy var imageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "로고7"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changeImageTap), for: .touchUpInside)
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("내 프로필 보기", for: .normal)
        button.setTitleColor(UIColor(named: "LabelsPrimary"), for: .normal)
        button.backgroundColor = UIColor(named: "BGPrimary")
        button.addTarget(self, action: #selector(myProfilebuttonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings() //위치변경 되었을때 뷰에 로드해줌
        fetchUserExperience()
        fetchUserLevelAndUpdateImage()
        
        // 로그인 상태가 아닐 때 로그인 화면 표시
        if Auth.auth().currentUser == nil {
            showLoginScreen()
        } else {
            setupView()
            fetchUserFirebase()
            setupTextField()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserFirebase()
        fetchUserExperience()
        if Auth.auth().currentUser == nil {
            view.removeAllSubviews()
            showLoginScreen()
        } else {
            fetchUserFirebase()
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "BGSecondary")
        navigationItem.title = "프로필"
        navigationItem.hidesBackButton = true
        view.addSubview(circleView)
        view.addSubview(imageButton)
        view.addSubview(profileButton)
        view.addSubview(tableView)
        
        setupConstraints()
        
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: "customTableCell")
        tableView.register(InformationTableCell.self, forCellReuseIdentifier: "informationTableCell")
    }
    
    private func setupConstraints() {
        let screenHeight = UIScreen.main.bounds.height

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            circleView.widthAnchor.constraint(equalToConstant: 120),
            circleView.heightAnchor.constraint(equalToConstant: 120),
            
            imageButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            imageButton.widthAnchor.constraint(equalToConstant: 100),
            imageButton.heightAnchor.constraint(equalToConstant: 100),
            
            profileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileButton.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 20),
            profileButton.widthAnchor.constraint(equalToConstant: 130),
            
            tableView.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc func myProfilebuttonTap() {
        
        guard let userId = LoginViewModel.shared.user?.id else {
            print("User ID is not available")
            return
        }
        
        let aboutMeViewController = AboutMeViewController(userId: userId)
        self.navigationController?.pushViewController(aboutMeViewController, animated: true)
    }
    
    
    @objc func changeNicknameButtonTap() {
        let nickname = NicknameViewController()
        present(nickname, animated: true)
        
        if let presentationController = nickname.presentationController as? UISheetPresentationController {
            presentationController.detents = [
                UISheetPresentationController.Detent.custom { _ in
                    return 213 // 원하는 높이로 조정
                }
            ]
            presentationController.preferredCornerRadius = 20 // 모서리 둥글기 설정 (선택 사항)
        }
    }
    
    @objc func changeLocationButtonTap() {
        let searchMapViewController = SearchMapViewController()
        let navigationController = UINavigationController(rootViewController: searchMapViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func inpoButtonTap() {
        textFieldContainer?.isHidden = false // 텍스트 필드가 있는 컨테이너를 표시
    }
    
    @objc func confirmButtonTapped() {
        textFieldContainer?.isHidden = true
    }
    //MARK: - Level설명
    private func setupTextField() {
        //Container 설정
        let container = UIView()
        container.backgroundColor = UIColor(named: "BGSecondary")
        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.2
        container.layer.shadowRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let textTitle = UILabel()
        textTitle.text = "단계란 무엇인가요?"
        textTitle.textColor = UIColor(named: "LabelsPrimary")
        textTitle.font = UIFont.boldSystemFont(ofSize: 14)
        textTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let textBody = UILabel()
        textBody.text = """
단계는 새싹 거래 간 후기 별점을 보고,새싹
캐릭터가 점점 성장하는 시스템입니다.
후기에 따라 단계는 하락할 수도 있습니다.
"""
        textBody.textColor = UIColor(named: "LabelsPrimary")
        textBody.numberOfLines = 0 // 여러 줄 텍스트를 지원
        textBody.font = UIFont.systemFont(ofSize: 14)
        textBody.translatesAutoresizingMaskIntoConstraints = false
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(textTitle)
        container.addSubview(textBody)
        container.addSubview(confirmButton)
        
        view.addSubview(container) // 'container'를 메인 뷰에 추가합니다.
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 300),
            container.heightAnchor.constraint(equalToConstant: 150),
            
            textTitle.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            textTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textTitle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            textBody.topAnchor.constraint(equalTo: textTitle.bottomAnchor, constant: 8),
            textBody.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textBody.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            confirmButton.topAnchor.constraint(equalTo: textBody.bottomAnchor, constant: 16),
            confirmButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        container.isHidden = true // 초기에는 숨김 상태로 설정
        textFieldContainer = container
        NotificationCenter.default.addObserver(self, selector: #selector(handleNicknameChanged), name: Notification.Name("NicknameChanged"), object: nil)
        
    }
    @objc func handleNicknameChanged() {
        fetchUserFirebase()
    }
    
    private func setupBindings() {
        LoginViewModel.shared.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateUI(with: user)
            }
            .store(in: &cancellables)
    }
    private func updateUI(with user: User?) {
        tableView.reloadData()
    }
    private func showLoginScreen() {
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    func fetchUserExperience() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("사용자 Id 불러오기 실패")
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("데이터 가져오는 중 오류 발생: \(error)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data(), let exp = data["exp"] as? Int else {
                print("경험치 정보를 가져오는 중 오류 발생")
                return
            }
            self.updateCircleView(withExperience: exp)
        }
    }
    
    private func updateCircleView(withExperience exp: Int) {
        let percentage = CGFloat(exp) / 100.0
        
        if let progressLayer = circleView.layer.sublayers?.first(where: { $0 is CAShapeLayer }) as? CAShapeLayer {
            progressLayer.strokeEnd = percentage
        }
    }
}
extension UIView {
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
