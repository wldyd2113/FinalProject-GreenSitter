//
//  AboutMeViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AboutMeViewController: UIViewController {
    private let reportsAndBlocksViewModel = ReportsAndBlocksViewModel()

    let db = Firestore.firestore()
    var user: User?
    var userId: String
    
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var sectionTitle = ["자기소개", "돌봄 정보"]
    
    lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "로고7")
        image.layer.cornerRadius = 60
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 70
        view.layer.masksToBounds = true
        
        // Progress layer
        let progressLayer = CAShapeLayer()
        progressLayer.strokeColor = UIColor(named: "DominentColor")?.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 70, y: 70), radius: 70, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        progressLayer.path = circularPath.cgPath
        view.layer.addSublayer(progressLayer)
        
        view.backgroundColor = UIColor(named: "SeparatorsOpaque")
        
        return view
    }()
    
    lazy var levelView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "DominentColor")
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var levelLabel: UILabel = {
        let label = UILabel()
        label.text = user?.levelPoint.rawValue
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = /*UIColor(named: "LabelsPrimary")*/ .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var levelIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "leaf.fill")
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = user?.nickname
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "LabelsPrimary")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = user?.location.address
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(named: "SeparatorsOpaque")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        view.backgroundColor = UIColor(named: "BGSecondary")
        
        setupNavigationBar()
        
        tableView.register(IntroductionTableCell.self, forCellReuseIdentifier: "introductionTableCell")
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: "customTableCell")
        
        view.addSubview(circleView)
        view.addSubview(profileImage)
        view.addSubview(levelView)
        levelView.addSubview(levelIcon) // levelIcon을 levelView의 서브뷰로 추가
        levelView.addSubview(levelLabel) // levelLabel을 levelView의 서브뷰로 추가
        view.addSubview(nicknameLabel)
        view.addSubview(separatorLine)
        view.addSubview(locationLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            circleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            circleView.widthAnchor.constraint(equalToConstant: 140),
            circleView.heightAnchor.constraint(equalToConstant: 140),
            
            profileImage.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            profileImage.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 120),
            profileImage.heightAnchor.constraint(equalToConstant: 120),
            
            levelView.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 40),
            levelView.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 10),
            levelView.widthAnchor.constraint(equalToConstant: 120),
            levelView.heightAnchor.constraint(equalToConstant: 30),
            
            levelIcon.leadingAnchor.constraint(equalTo: levelView.leadingAnchor, constant: 10),
            levelIcon.centerYAnchor.constraint(equalTo: levelView.centerYAnchor),
            levelIcon.widthAnchor.constraint(equalToConstant: 20),
            levelIcon.heightAnchor.constraint(equalToConstant: 20),
            
            levelLabel.leadingAnchor.constraint(equalTo: levelIcon.trailingAnchor, constant: 10),
            levelLabel.centerYAnchor.constraint(equalTo: levelView.centerYAnchor),
            levelLabel.trailingAnchor.constraint(equalTo: levelView.trailingAnchor, constant: -10),
            
            nicknameLabel.topAnchor.constraint(equalTo: levelView.bottomAnchor, constant: 10),
            nicknameLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 50),
            nicknameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            separatorLine.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 50),
            separatorLine.widthAnchor.constraint(equalToConstant: 150), // 선의 길이
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            locationLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 50),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        fetchUserFirebase(userId: userId)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userAboutMeUpdated), name: NSNotification.Name("UserAboutMeUpdated"), object: nil)
        fetchUserExperience()
        
    }
    @objc func userAboutMeUpdated() {
        // 유저 데이터를 다시 불러오기
        fetchUserFirebase(userId: userId)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - exp테두리설정
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
    
    private func setupNavigationBar() {
        navigationItem.title = "프로필"
            
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        if currentUserID != userId {
            setupBlockButton(with: userId)
        }
    }
    
    private func setupBlockButton(with userId: String) {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "신고하기", image: UIImage(systemName: "light.beacon.max.fill")) { [weak self] _ in
                self?.presentReportAlert(for: userId)
            },
            UIAction(title: "차단하기", image: UIImage(systemName: "person.slash.fill")) { [weak self] _ in
                self?.blockUser(userId: userId)
            }
        ])
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        menuButton.tintColor = .labelsPrimary
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = menuBarButtonItem
    }
    
    // MARK: - 신고 기능 구현
    private func presentReportAlert(for userId: String) {
        let alertController = UIAlertController(title: "신고하기", message: "신고 사유를 입력하세요.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "신고 사유를 입력하세요"
        }
        
        let reportAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let reason = alertController.textFields?.first?.text, !reason.isEmpty else {
                self?.presentErrorAlert(message: "신고 사유를 입력해야 합니다.")
                return
            }
            
            self?.reportUser(userId: userId, reason: reason)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func reportUser(userId: String, reason: String) {
        
        reportsAndBlocksViewModel.reportItem(reportedId: userId, reportType: .user, reason: reason) { result in
            switch result {
            case .success():
                self.presentConfirmationAlert(message: "신고가 완료되었습니다.")
            case .failure(let error):
                print("Failed to save report: \(error.localizedDescription)")
                self.presentErrorAlert(message: "신고 저장에 실패했습니다.")
            }
        }
    }

    private func presentConfirmationAlert(message: String) {
        let alert = UIAlertController(title: "완료", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 차단 기능 구현
    private func blockUser(userId: String) {
        reportsAndBlocksViewModel.blockItem(blockedId: userId, blockType: .user) { result in
            switch result {
            case .success():
                print("Block saved successfully.")
                self.updateUIForBlockedPost()
            case .failure(let error):
                print("Failed to save block: \(error.localizedDescription)")
            }
        }
    }

    private func updateUIForBlockedPost() {
        let alert = UIAlertController(title: "차단 완료", message: "이 유저는 더 이상 볼 수 없습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
