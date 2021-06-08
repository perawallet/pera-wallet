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
//  ContactAssetCell.swift

import UIKit

class ContactAssetCell: BaseCollectionViewCell<ContactAssetView> {
    
    weak var delegate: ContactAssetCellDelegate?
    
    override func configureAppearance() {
        contextView.layer.cornerRadius = 12.0
    }
    
    override func setListeners() {
        super.setListeners()
        contextView.delegate = self
    }
}

extension ContactAssetCell: ContactAssetViewDelegate {
    func contactAssetViewDidTapSendButton(_ contactAssetView: ContactAssetView) {
        delegate?.contactAssetCellDidTapSendButton(self)
    }
}

protocol ContactAssetCellDelegate: class {
    func contactAssetCellDidTapSendButton(_ contactAssetCell: ContactAssetCell)
}
