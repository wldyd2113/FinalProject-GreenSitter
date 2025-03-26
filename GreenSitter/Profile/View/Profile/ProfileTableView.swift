//
//  ProfileViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let user = LoginViewModel.shared.user
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            // "이름" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileTableViewCell
            (cell as! ProfileTableViewCell).titleLabel.text = "이름"
            (cell as! ProfileTableViewCell).bodyLabel.text = user?.nickname
            (cell as! ProfileTableViewCell).bodyLabel.textColor = UIColor(named: "LabelsPrimary")
            (cell as! ProfileTableViewCell).actionButton.isHidden = false
            (cell as! ProfileTableViewCell).actionButton.setTitle("변경", for: .normal)
            // 이전 타겟을 모두 제거하고 새로운 타겟을 추가
            (cell as! ProfileTableViewCell).actionButton.removeTarget(nil, action: nil, for: .allEvents)
            (cell as! ProfileTableViewCell).actionButton.addTarget(self, action: #selector(changeNicknameButtonTap), for: .touchUpInside)

            (cell as! ProfileTableViewCell).setIconHidden(true)
            
            
        case (0, 1):
            // "사는 곳" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileTableViewCell
            let profileCell = cell as! ProfileTableViewCell

            profileCell.titleLabel.text = "사는 곳"
            
            profileCell.bodyLabel.text = user?.location.address
            
            profileCell.actionButton.isHidden = false
            profileCell.actionButton.setTitle("변경", for: .normal)
            profileCell.actionButton.setImage(nil, for: .normal)
            
            
            // 이전 타겟을 모두 제거하고 새로운 타겟을 추가
            profileCell.actionButton.removeTarget(nil, action: nil, for: .allEvents)
            profileCell.actionButton.addTarget(self, action: #selector(changeLocationButtonTap), for: .touchUpInside)

            profileCell.setIconHidden(true)
            
        case (0, 2):
             cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileTableViewCell
             let profileCell = cell as! ProfileTableViewCell
             profileCell.titleLabel.text = nil
             profileCell.bodyLabel.text = user?.levelPoint.rawValue
             
             // Fetch level image URL based on user level
             if let level = user?.levelPoint, let imageURLString = imageURLForLevel(level), let httpsURLString = convertToHttpsURL(gsURL: imageURLString), let imageURL = URL(string: httpsURLString) {
                 // Asynchronously load the image
                 downloadImage(from: httpsURLString) { image in
                     DispatchQueue.main.async {
                         if let image = image {
                             profileCell.iconImageView.image = image
                         } else {
                             profileCell.iconImageView.image = UIImage(named: "defaultImage") // Placeholder image
                         }
                     }
                 }
             } else {
                 profileCell.iconImageView.image = UIImage(named: "defaultImage") // Placeholder image
             }
             
             profileCell.actionButton.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
             profileCell.actionButton.setTitle(nil, for: .normal) // '변경' 텍스트 제거
             profileCell.actionButton.removeTarget(nil, action: nil, for: .allEvents) // 기존 타겟 제거
             profileCell.actionButton.addTarget(self, action: #selector(inpoButtonTap), for: .touchUpInside)
             profileCell.actionButton.isHidden = false
             profileCell.setIconHidden(false)
            // 레벨 이미지를 설정

        case (1, 0):
            // "내가 맡긴 식물" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "leaf.fill")
            (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
            (cell as! CustomTableCell).textsLabel.text = "내가 맡긴 식물"
            (cell as! CustomTableCell).textsLabel.textColor = UIColor(named: "LabelsPrimary")
            
        case (1, 1):
            // "내가 쓴 돌봄 후기" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.rectangle.fill")
            (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
            (cell as! CustomTableCell).textsLabel.text = "내가 쓴 돌봄 후기"
            (cell as! CustomTableCell).textsLabel.textColor = UIColor(named: "LabelsPrimary")
            
        case (2, 0):
            // "로그아웃" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "rectangle.portrait.and.arrow.forward.fill")
            (cell as! CustomTableCell).iconImage.tintColor = .systemBlue
            (cell as! CustomTableCell).textsLabel.text = "로그아웃"
            (cell as! CustomTableCell).textsLabel.textColor = .systemBlue
            
        case (2, 1):
            // "회원탈퇴" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "person.crop.circle.badge.xmark")
            (cell as! CustomTableCell).iconImage.tintColor = .systemRed
            (cell as! CustomTableCell).textsLabel.text = "회원탈퇴"
            (cell as! CustomTableCell).textsLabel.textColor = .systemRed
            
        case (3, 0):
            // "서비스 이용약관" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "informationTableCell", for: indexPath) as! InformationTableCell
            (cell as! InformationTableCell).infoLabel.text = "서비스 이용약관"
            
        case (3, 1):
            // "개인정보 처리 방침" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "informationTableCell", for: indexPath) as! InformationTableCell
            (cell as! InformationTableCell).infoLabel.text = "개인정보 처리 방침"
            
        case (3, 2):
            // "비즈니스 개인정보 처리방침" 셀
            cell = tableView.dequeueReusableCell(withIdentifier: "informationTableCell", for: indexPath) as! InformationTableCell
            (cell as! InformationTableCell).infoLabel.text = "위치기반서비스 이용약관"
            
        default:
            cell = UITableViewCell()
        }
        
        let cornerRadius: CGFloat = 10
        var maskedCorners: CACornerMask = []
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstRow && isLastRow {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstRow {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.layer.cornerRadius = cornerRadius
        cell.layer.maskedCorners = maskedCorners
        cell.layer.masksToBounds = true
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case(1,0):
            let leavePlantListViewController = LeavePlantListViewController()
            self.navigationController?.pushViewController(leavePlantListViewController, animated: true)
        case(1,1):
            let writeReviewViewController = WriteReviewViewController()
            self.navigationController?.pushViewController(writeReviewViewController, animated: true)
        case (2, 0):
            logout()
        case (2, 1):
            accountDeletion()
        case(3,0):
            let serviceViewController = ServiceViewController()
            self.navigationController?.pushViewController(serviceViewController, animated: true)
        case(3,1):
            let locationServiceViewController = LocationServiceViewController()
            self.navigationController?.pushViewController(locationServiceViewController, animated: true)
        case(3,2):
            let personalInfomationViewController = PersonalinfomationViewController()
            self.navigationController?.pushViewController(personalInfomationViewController, animated: true)
        default:
            break
        }
    }
}
