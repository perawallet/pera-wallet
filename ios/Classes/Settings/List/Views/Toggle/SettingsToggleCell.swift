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
//  SettingsToggleCell.swift

import UIKit

final class SettingsToggleCell: BaseCollectionViewCell<SettingsToggleView> {
    weak var delegate: SettingsToggleCellDelegate?
    
    override func setListeners() {
        contextView.setListeners()
        contextView.delegate = self
    }
    
    func bindData(_ viewModel: SettingsToggleViewModel) {
        contextView.bindData(viewModel)
    }
}

extension SettingsToggleCell: SettingsToggleContextViewDelegate {
    func settingsToggleView(_ settingsToggleContextView: SettingsToggleView, didChangeValue value: Bool) {
        delegate?.settingsToggleCell(self, didChangeValue: value)
    }
}

protocol SettingsToggleCellDelegate: AnyObject {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool)
}
