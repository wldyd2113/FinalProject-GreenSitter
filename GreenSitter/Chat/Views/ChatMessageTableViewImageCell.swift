//
//  ChatMessageTableViewImageCell.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/21/24.
//

import UIKit

class ChatMessageTableViewImageCell: UITableViewCell {
    var isIncoming: Bool = false {
        didSet {
            setupUI()
        }
    }
    
    var isRead: Bool = false {
        didSet {
            isReadLabel.text = isRead ? "" : "읽지 않음"
        }
    }
    
    var images: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.updateImageStackView()
            }
        }
    }
    
    var imageViews = [UIImageView]()
    
    lazy var imageStackView: UIStackView = {
       let imageStackView = UIStackView(arrangedSubviews: imageViews)
        imageStackView.axis = .horizontal
        imageStackView.spacing = 10
        imageStackView.distribution = .fillEqually
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        return imageStackView
    }()
    
    lazy var firstVStackView: UIStackView = {
        let firstVStackView = UIStackView()
        firstVStackView.axis = .vertical
        firstVStackView.spacing = 10
        firstVStackView.distribution = .fillEqually
        return firstVStackView
    }()
    
    lazy var secondVStackView: UIStackView = {
        let secondVStackView = UIStackView()
        secondVStackView.axis = .vertical
        secondVStackView.spacing = 10
        secondVStackView.distribution = .fillEqually

        return secondVStackView
    }()
    
    lazy var morePhotosLabel: UILabel = {
        let morePhotosLabel = UILabel()
        morePhotosLabel.layer.cornerRadius = 10
        morePhotosLabel.backgroundColor = .white
        morePhotosLabel.clipsToBounds = true
        morePhotosLabel.translatesAutoresizingMaskIntoConstraints = false
        morePhotosLabel.numberOfLines = 0
        morePhotosLabel.textAlignment = .center
        return morePhotosLabel
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo7")
        
        return imageView
    }()
    
    // TODO: - 오전 12시에 날짜 출력
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .fillTertiary
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        label.text = "2024년 8월 19일"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "오후 1:43"
        label.textColor = .labelsSecondary
        label.font = UIFont.systemFont(ofSize: 11)
        
        return label
    }()
    
    lazy var isReadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .complementary
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        updateImageStackView()
        contentView.addSubview(imageStackView)
        contentView.addSubview(timeLabel)
        
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        
        if isIncoming {
            contentView.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.topAnchor.constraint(equalTo: imageStackView.topAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                imageStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                imageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                imageStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                
                timeLabel.bottomAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: imageStackView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100),
                
                timeLabel.bottomAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                
                imageStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                imageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                imageStackView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            ])
        }
    }
    
    private func updateImageStackView() {
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        firstVStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        secondVStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        imageViews = images.map { image in
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = 10
            imageView.backgroundColor = .white
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            ])
            return imageView
        }
        
        switch imageViews.count {
        case 0:
            break
        case 1...3:
            imageViews.forEach { imageStackView.addArrangedSubview($0) }
        case 4:
            firstVStackView.addArrangedSubview(imageViews[0])
            secondVStackView.addArrangedSubview(imageViews[1])
            firstVStackView.addArrangedSubview(imageViews[2])
            secondVStackView.addArrangedSubview(imageViews[3])
            
            imageStackView.addArrangedSubview(firstVStackView)
            imageStackView.addArrangedSubview(secondVStackView)
        default:
            morePhotosLabel.text = "+ \(imageViews.count - 3)\n더보기"
            
            firstVStackView.addArrangedSubview(imageViews[0])
            secondVStackView.addArrangedSubview(imageViews[1])
            firstVStackView.addArrangedSubview(imageViews[2])
            secondVStackView.addArrangedSubview(morePhotosLabel)
            
            imageStackView.addArrangedSubview(firstVStackView)
            imageStackView.addArrangedSubview(secondVStackView)
        }
    }
}

