// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  ContactInfoViewModel.swift

import UIKit

class ContactInfoViewModel {
    func configure(_ userInformationView: UserInformationView, with contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 88.0, height: 88.0))
            userInformationView.userImageView.image = resizedImage
        }
        
        userInformationView.setAddButtonHidden(true)
        userInformationView.contactNameInputView.inputTextField.text = contact.name
        
        if let address = contact.address {
            userInformationView.algorandAddressInputView.value = address
        }
    }
    
    func configure(_ cell: ContactAssetCell, at indexPath: IndexPath, with contactAccount: Account?) {
        if indexPath.item == 0 {
            cell.contextView.assetNameView.removeId()
            cell.contextView.assetNameView.setName("asset-algos-title".localized)
            cell.contextView.assetNameView.removeUnitName()
        } else {
            guard let account = contactAccount else {
                return
            }
            
            let assetDetail = account.assetDetails[indexPath.item - 1]
            
            if !assetDetail.isVerified {
                cell.contextView.assetNameView.removeVerified()
            }
            
            cell.contextView.assetNameView.setId("\(assetDetail.id)")
            
            if assetDetail.hasBothDisplayName() {
                cell.contextView.assetNameView.setAssetName(for: assetDetail)
                return
            }
            
            if assetDetail.hasOnlyAssetName() {
                cell.contextView.assetNameView.setName(assetDetail.assetName)
                cell.contextView.assetNameView.removeUnitName()
                return
            }
            
            if assetDetail.hasOnlyUnitName() {
                cell.contextView.assetNameView.setName(assetDetail.unitName)
                cell.contextView.assetNameView.removeName()
                return
            }
            
            if assetDetail.hasNoDisplayName() {
                cell.contextView.assetNameView.setName("title-unknown".localized)
                cell.contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
                cell.contextView.assetNameView.removeUnitName()
                return
            }
        }
    }
}
