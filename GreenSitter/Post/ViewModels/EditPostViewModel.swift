//
//  EditPostViewModel.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit
import PhotosUI

class EditPostViewModel: ObservableObject {
    @Published var postTitle: String
    @Published var postBody: String
    @Published var postImages: [UIImage] = []
    @Published var selectedImages: [UIImage] = []
    @Published var location: Location?
    @Published var imageURLsToDelete: [String] = []
    
    private var firestoreManager = FirestoreManager()
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    private let postId: String
    private let postType: PostType
    
    
    init(post: Post) {
        self.postId = post.id
        self.postTitle = post.postTitle
        self.postBody = post.postBody
        self.location = post.location
        self.postType = post.postType
        
        // 옵셔널 바인딩을 사용하여 postImages 처리
        if let postImageURLs = post.postImages {
            loadExistingImages(from: postImageURLs) {
                print("All images loaded")
            }
        }
    }
    
    func loadExistingImages(from urls: [String], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for urlString in urls {
            group.enter()
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer { group.leave() }
                
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data) else {
                    return
                }
                
                DispatchQueue.main.async {
                    image.accessibilityIdentifier = urlString
                    self.postImages.append(image)
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func addSelectedImages(results: [PHPickerResult], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self?.selectedImages.append(image)
                        }
                    } else {
                        print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func removeSelectedImage(_ index: Int) {
        guard index >= 0 && index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func removeExistingImage(_ urlString: String) {
        if let index = postImages.firstIndex(where: { $0.accessibilityIdentifier == urlString }) {
            postImages.remove(at: index)
            imageURLsToDelete.append(urlString)
        }
    }
    
    private func uploadNewImages(completion: @escaping (Result<[String], Error>) -> Void) {
        var imageURLs: [String] = []
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                group.leave()
                continue
            }
            
            let imageName = UUID().uuidString + ".jpg"
            let storageRef = storage.reference().child("post_images/\(imageName)")
            
            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    group.leave()
                    completion(.failure(error))
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        group.leave()
                        completion(.failure(error))
                        return
                    }
                    
                    if let imageURL = url?.absoluteString {
                        imageURLs.append(imageURL)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(imageURLs))
        }
    }
    
    private func deleteRemovedImages(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        
        for urlString in imageURLsToDelete {
            group.enter()
            let storageRef = storage.reference(forURL: urlString)
            storageRef.delete { error in
                if let error = error {
                    group.leave()
                    completion(.failure(error))
                    return
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(()))
        }
    }
    
    func updatePost(completion: @escaping (Result<Post, Error>) -> Void) {
        deleteRemovedImages { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.uploadNewImages { result in
                    switch result {
                    case .success(let newImageURLs):
                        let updatedPost = Post(
                            id: self.postId,
                            enabled: true,
                            createDate: Date(),
                            updateDate: Date(),
                            userId: "currentUserId",  // 실제 사용자 ID를 여기에 넣어야 합니다
                            profileImage: "currentProfileImage",  // 프로필 이미지 URL
                            nickname: "currentNickname",  // 사용자 닉네임
                            userLocation: self.location ?? Location.seoulLocation,
                            userNotification: false,
                            postType: self.postType,
                            postTitle: self.postTitle,
                            postBody: self.postBody,
                            postImages: newImageURLs,
                            postStatus: .beforeTrade,
                            location: self.location
                        )
                        
                        do {
                            let postData = try Firestore.Encoder().encode(updatedPost)
                            self.db.collection("posts").document(self.postId).setData(postData) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(updatedPost))
                                }
                            }
                        } catch {
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
