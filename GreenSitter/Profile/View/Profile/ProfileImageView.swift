//
//  ProfileImageViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Photos

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func changeImageTap() {
        // 권한 상태를 확인합니다
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.presentImagePickerController()
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showPhotoLibraryPermissionAlert()
                }
            case .notDetermined:
                // 권한 요청이 아직 결정되지 않은 경우, 이미지 선택기 표시
                DispatchQueue.main.async {
                    self.presentImagePickerController()
                }
            @unknown default:
                break
            }
        }
    }
    private func presentImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showPhotoLibraryPermissionAlert() {
        let alertController = UIAlertController(
            title: "사진 라이브러리 접근 권한 필요",
            message: "사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        if let editedImage = info[.editedImage] as? UIImage {
            uploadImage(image: editedImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updatePostsImageURL(forUserId: userId, imageURL: imageURL)
                    self.updateUserProfileImageURL(forUserId: userId, imageURL: imageURL)
                    self.imageButton.setImage(editedImage, for: .normal)
                }
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadImage(image: originalImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updatePostsImageURL(forUserId: userId, imageURL: imageURL)
                    self.updateUserProfileImageURL(forUserId: userId, imageURL: imageURL)
                    self.imageButton.setImage(originalImage, for: .normal)
                    self.updateChatUserImageURL(forUserId: userId, imageURL: imageURL)
                    self.updateChatPostsImageURL(forUserId: userId, imageURL: imageURL)

                }
            }
        }
    }
    
    func updateUserProfileImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).updateData(["profileImage": imageURL]) { error in
            if let error = error {
                print("Error updating profileImageURL in user document: \(error.localizedDescription)")
            } else {
                print("ProfileImageURL successfully updated in user document!")
            }
        }
    }

    
    func updatePostsImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in posts collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["profileImage": imageURL]) { error in
                    if let error = error {
                        print("Error updating profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }
    
    func updateChatUserImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("chatRooms").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in chat user collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["userProfileImage": imageURL]) { error in
                    if let error = error {
                        print("Error updating chat user profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL chat user successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }
    
    func updateChatPostsImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("chatRooms").whereField("postUserId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in chat posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in chat posts collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["postUserProfileImage": imageURL]) { error in
                    if let error = error {
                        print("Error updating chat posts profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL chat posts successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }

}
