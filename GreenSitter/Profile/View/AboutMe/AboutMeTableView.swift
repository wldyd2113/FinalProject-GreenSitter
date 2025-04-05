//
//  AboutMeTableViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/14/24.
//

import UIKit
import FirebaseAuth

extension AboutMeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    //MARK: - 섹션의 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    //MARK: - 섹션의 행수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "introductionTableCell", for: indexPath) as! IntroductionTableCell
            let aboutMeText = user?.aboutMe ?? "자기소개를 입력해주세요"
            print("Cell for row at indexPath \(indexPath): aboutMeText = \(aboutMeText)")
            (cell as! IntroductionTableCell).bodyLabel.text = aboutMeText
            (cell as! IntroductionTableCell).bodyLabel.textColor = UIColor(named: "LabelsPrimary")
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "heart.fill")
                (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 후기"
                (cell as! CustomTableCell).textsLabel.textColor = UIColor(named: "LabelsPrimary")
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.clipboard.fill")
                (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 기록"
                (cell as! CustomTableCell).textsLabel.textColor = UIColor(named: "LabelsPrimary")
            }

        default:
            cell = UITableViewCell()
        }
        
        // 셀의 모서리와 테두리 설정
        configureCellAppearance(cell, at: indexPath, in: tableView)
        cell.contentView.backgroundColor = UIColor(named: "BGPrimary")
        return cell
    }

    
    func configureCellAppearance(_ cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        let cornerRadius: CGFloat = 10.0
        var maskedCorners: CACornerMask = []
        
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstRow && isLastRow {
            // 첫 번째와 마지막 셀의 모서리만 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstRow {
            // 첫 번째 셀의 상단 모서리만 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            // 마지막 셀의 하단 모서리만 둥글게
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        // 셀의 외관 설정
        cell.contentView.layer.cornerRadius = cornerRadius
        cell.contentView.layer.maskedCorners = maskedCorners
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.backgroundColor = .white
    }
    
    //MARK: - 셀 높이 조정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    //MARK: - 헤더뷰를 반환하는 Method
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let titleLabel = UILabel()
            titleLabel.text = sectionTitle[section]
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = UIColor(named: "SeparatorsNonOpaque")
            headerView.addSubview(titleLabel)
            
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                return headerView
            }
            
            if currentUserID == userId {
                let editButton = UIButton(type: .system)
                editButton.setTitle("수정하기", for: .normal)
                editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
                editButton.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview(editButton)
                
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                    titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                    
                    editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                    editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                    titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
                ])
            }
            
            return headerView
        }
        
        let defaultHeaderView = UIView()
        defaultHeaderView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.text = sectionTitle[section]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor(named: "SeparatorsNonOpaque")
        defaultHeaderView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: defaultHeaderView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: defaultHeaderView.centerYAnchor)
        ])
        
        return defaultHeaderView
    }


    //MARK: - cell 클릭시 발생하는 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserId = self.userId // 현재 프로필의 userId를 사용

        if indexPath.section == 1 && indexPath.row == 0 {
           let reviewViewController = ReviewListViewController(userId: targetUserId)
           navigationController?.pushViewController(reviewViewController, animated: true)
       }
        else if indexPath.section == 1 && indexPath.row == 1 {
            let careRecordViewController = CareRecordViewController(userId: targetUserId)
            navigationController?.pushViewController(careRecordViewController, animated: true)
        }

    }
}
