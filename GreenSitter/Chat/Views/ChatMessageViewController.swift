//
//  ChatMessageViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatMessageViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    
    // 임시 데이터
//    var messages: [String] = ["Hello!", "How are you?", "I'm fine, thanks!", "What about you?", "I'm good too!", "어디까지 나오는지 테스트해보자아아아아아아아아아아아아아아아앙아아아아아", "읽었어?"]
//    var isIncoming: [Bool] = [false, true, false, false, true, true, false]
//    var isRead: [Bool] = [true, true, true, true, true, true, false]
    
    // 메세지 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .bgSecondary
        // 셀 구분선 제거
        tableView.separatorStyle = .none
        // 셀 선택 불가능하게 설정
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatViewModel?.loadMessages { [weak self] in
            guard let self = self else { return }
            
            self.chatViewModel?.updateUI = { [weak self] in
                self?.setupUI()
            }
            
            self.chatViewModel?.updateUI?()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = .bgSecondary
        
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.register(ChatMessageTableViewImageCell.self, forCellReuseIdentifier: "ChatMessageImageCell")
        tableView.register(ChatMessageTableViewPlanCell.self, forCellReuseIdentifier: "ChatMessagePlanCell")
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }

}

extension ChatMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel?.messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch chatViewModel?.messages?[indexPath.row].messageType {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            cell.backgroundColor = .clear
            cell.messageLabel.text = chatViewModel?.messages?[indexPath.row].text
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageImageCell", for: indexPath) as! ChatMessageTableViewImageCell
            cell.backgroundColor = .clear
            
            let imageCounts: Int = chatViewModel?.messages?[indexPath.row].image?.count ?? 0
            var progressImages = [UIImage]()
            
            for _ in 0..<imageCounts {
                if let photoImage = UIImage(systemName: "photo") {
                    progressImages.append(photoImage)
                }
            }
            cell.images = progressImages
            
            if let imagePaths = chatViewModel?.messages?[indexPath.row].image {
                Task {
                    let images = await chatViewModel?.loadChatImages(imagePaths: imagePaths)
                    print("images : \(String(describing: images))")
                    DispatchQueue.main.async {
                        cell.images = images ?? []
                    }
                }
            }
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            return cell
        case .plan:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessagePlanCell", for: indexPath) as! ChatMessageTableViewPlanCell
            cell.backgroundColor = .clear
            
            let planDate = chatViewModel?.messages?[indexPath.row].plan?.planDate
            if let planDate = planDate {
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateStyle = .medium
                let dateString = dateFormatter.string(from: planDate)
                
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                let timeString = dateFormatter.string(from: planDate)
                
                cell.planDateLabel.text = "날짜: \(dateString)"
                cell.planTimeLabel.text = "시간: \(timeString)"
            }
            
            let planPlace = chatViewModel?.messages?[indexPath.row].plan?.planPlace?.placeName ?? ""
            cell.planPlaceLabel.text = "장소: \(planPlace)"
            
            if let plan = chatViewModel?.messages?[indexPath.row].plan {
                let makePlanViewModel = MakePlanViewModel(date: plan.planDate, planPlace: plan.planPlace, ownerNotification: plan.ownerNotification, sitterNotification: plan.sitterNotification, progress: 3, isPlaceSelected: true)
                cell.detailButtonAction = {
                    self.present(MakePlanViewController(viewModel: makePlanViewModel), animated: true)
                }
            }
            
            if let planPlace = chatViewModel?.messages?[indexPath.row].plan?.planPlace {
                cell.placeButtonAction = {
                    let navigationController = UINavigationController(rootViewController: PlanPlaceDetailViewController(location: planPlace))
                    self.present(navigationController, animated: true)
                }
            }
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            
            return cell
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            cell.backgroundColor = .clear
            cell.messageLabel.text = chatViewModel?.messages?[indexPath.row].text
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            
            return cell
        }
    }
}

extension ChatMessageViewController: UITableViewDelegate {
    
}
