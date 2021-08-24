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
//  AccountHeaderSupplementaryView.swift

import UIKit

class AccountHeaderSupplementaryView: BaseSupplementaryView<AccountHeaderView> {
    
    weak var delegate: AccountHeaderSupplementaryViewDelegate?
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func setListeners() {
        contextView.delegate = self
    }

    func bind(_ viewModel: AccountHeaderSupplementaryViewModel) {
        contextView.bind(viewModel)
    }
}

extension AccountHeaderSupplementaryView: AccountHeaderViewDelegate {
    func accountHeaderViewDidTapQRButton(_ accountHeaderView: AccountHeaderView) {
        delegate?.accountHeaderSupplementaryViewDidTapQRButton(self)
    }
    
    func accountHeaderViewDidTapOptionsButton(_ accountHeaderView: AccountHeaderView) {
        delegate?.accountHeaderSupplementaryViewDidTapOptionsButton(self)
    }
}

protocol AccountHeaderSupplementaryViewDelegate: AnyObject {
    func accountHeaderSupplementaryViewDidTapQRButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView)
    func accountHeaderSupplementaryViewDidTapOptionsButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView)
}
