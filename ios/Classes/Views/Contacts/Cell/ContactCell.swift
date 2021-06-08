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
//  ContactCell.swift

import UIKit

class ContactCell: BaseCollectionViewCell<ContactContextView> {
    
    weak var delegate: ContactCellDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.userImageView.image = img("icon-user-placeholder")
    }

    func bind(_ viewModel: ContactsViewModel) {
        contextView.bind(viewModel)
    }
}

extension ContactCell: ContactContextViewDelegate {
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView) {
        delegate?.contactCellDidTapQRDisplayButton(self)
    }
}

protocol ContactCellDelegate: class {
    func contactCellDidTapQRDisplayButton(_ cell: ContactCell)
}
