//
//  NicknameViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class NicknameViewController: UIViewController,UITextFieldDelegate {
    // MARK: - Properties
    var user: User?
    let db = Firestore.firestore()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이름 변경"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var nicknameTextfield: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .fillPrimary
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var nicknameStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = .bgPrimary
        nicknameTextfield.delegate = self
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(nicknameTextfield)
        view.addSubview(nicknameStatusLabel)
        view.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            nicknameTextfield.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nicknameTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextfield.widthAnchor.constraint(equalToConstant: 350),
            
            nicknameStatusLabel.topAnchor.constraint(equalTo: nicknameTextfield.bottomAnchor, constant: 10),
            nicknameStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            completeButton.topAnchor.constraint(equalTo: nicknameStatusLabel.bottomAnchor, constant: 30),
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 350),
            completeButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        fetchUserFirebase()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
