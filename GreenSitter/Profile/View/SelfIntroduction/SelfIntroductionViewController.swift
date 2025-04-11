//
//  SelfIntroductionViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/18/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SelfIntroductionViewController: UIViewController {
    var user: User?
    let db = Firestore.firestore()
    
    lazy var titleLabel: UILabel = {
        let label =  UILabel()
        label.text = "자기소개"
        label.textColor = UIColor(named: "LabelsPrimary")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var introductionTextView: UITextView = {
       let textView = UITextView()
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = user?.aboutMe ?? "자기소개를 입력하세요"
        textView.textColor = UIColor(named: "LabelsPrimary")
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "SeparatorsOpaque")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        return button
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.backgroundColor = UIColor(named: "DominentColor")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(completeButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGPrimary")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(introductionTextView)
        view.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            introductionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            introductionTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            introductionTextView.widthAnchor.constraint(equalToConstant: 350),
            introductionTextView.heightAnchor.constraint(equalToConstant: 250),
            
            
            completeButton.topAnchor.constraint(equalTo: introductionTextView.bottomAnchor, constant: 30),
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 350),
            completeButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        fetchUserFirebase()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
