//
//  LeavePlantListViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/20/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeavePlantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var post: [Post] = []
    let viewModel = LeavePlantListViewModel()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CareRecordTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "내가 맡긴 식물"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        fetchPostFirebase()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = post[indexPath.row]
        let postId = selectedPost.id
        print("전달된 postId: \(postId)")
        let postDetailViewController = PostDetailViewController(postId: postId)
        navigationController?.pushViewController(postDetailViewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CareRecordTableViewCell
        
        let currentPost = post[indexPath.row]
        if currentPost.postStatus.rawValue == "거래완료" {
            cell.statusView.backgroundColor = UIColor(named: "SeparatorsOpaque")
        } else {
            cell.statusView.backgroundColor = UIColor(named: "DominentColor")
        }
        cell.statusLabel.text = currentPost.postStatus.rawValue
        cell.titleLabel.text = currentPost.postTitle
        cell.bodyLabel.text = currentPost.postBody
        cell.timeLabel.text = DateFormatter.localizedString(from: currentPost.updateDate, dateStyle: .short, timeStyle: .short)
        if let imageURL = currentPost.postImages?.first {
            loadImage(from: imageURL) { image in
                DispatchQueue.main.async {
                    cell.plantImage.image = image ?? UIImage(named: "logo7")
                }
            }
        } else {
            cell.plantImage.image = UIImage(named: "logo7")
        }
        return cell
    }
}
