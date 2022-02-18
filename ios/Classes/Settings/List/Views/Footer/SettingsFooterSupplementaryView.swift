// Copyright 2022 Pera Wallet, LDA

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
//  SettingsFooterSupplementaryView.swift

import UIKit

class SettingsFooterSupplementaryView: BaseSupplementaryView<SettingsFooterView> {
    
    weak var delegate: SettingsFooterSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.setListeners()
        contextView.delegate = self
    }
}

extension SettingsFooterSupplementaryView: SettingsFooterViewDelegate {
    func settingsFooterViewDidTapLogoutButton(_ settingsFooterView: SettingsFooterView) {
        delegate?.settingsFooterSupplementaryViewDidTapLogoutButton(self)
    }
}

protocol SettingsFooterSupplementaryViewDelegate: AnyObject {
    func settingsFooterSupplementaryViewDidTapLogoutButton(_ settingsFooterSupplementaryView: SettingsFooterSupplementaryView)
}
