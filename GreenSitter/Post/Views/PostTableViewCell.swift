//
//  PostTableViewCell.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/21/24.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

class PostTableViewCell: UITableViewCell {
    
    // Define custom labels
    private let postStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .dominent
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.labelsPrimary
        label.numberOfLines = 1
        return label
    }()
    
    private let postBodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.labelsSecondary
        label.numberOfLines = 2
        return label
    }()
    
    private let postDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .labelsSecondary
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(postStatusLabel)
        contentView.addSubview(verticalStackView)
        contentView.addSubview(postImageView)
        
        verticalStackView.addArrangedSubview(postTitleLabel)
        verticalStackView.addArrangedSubview(postBodyLabel)
        verticalStackView.addArrangedSubview(postDateLabel)
        
        NSLayoutConstraint.activate([
            postStatusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            postStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postStatusLabel.widthAnchor.constraint(equalToConstant: 40),
            postStatusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            verticalStackView.topAnchor.constraint(equalTo: postStatusLabel.bottomAnchor, constant: 8),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: postImageView.leadingAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            postImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            postImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.widthAnchor.constraint(equalToConstant: 80),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with post: Post) {
        postStatusLabel.text = post.postStatus.rawValue
        postTitleLabel.text = post.postTitle
        postBodyLabel.text = post.postBody
        postDateLabel.text = timeAgoSinceDate(post.createDate)
        
        guard let postImages = post.postImages, !postImages.isEmpty else {
            postImageView.isHidden = true // 이미지가 없으면 이미지 뷰를 숨김
            return
        }
        
        postImageView.isHidden = false // 이미지가 있으면 이미지 뷰를 보이도록 설정
        
        if let imageUrl = postImages.first {
            loadImage(from: imageUrl) // Firestore에서 이미지 URL을 로드
        } else {
            postImageView.image = nil
        }
    }
    
    // Firebase Storage에서 이미지를 로드하여 표시
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            postImageView.image = UIImage(named: "defaultImage")
            return
        }
        
        // 비동기적으로 이미지 로드
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.postImageView.image = UIImage(named: "defaultImage")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.postImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
}

