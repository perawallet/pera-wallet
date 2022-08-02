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
//   SettingsHeaderViewModel.swift

import Foundation
import MacaroonUIKit

final class SingleGrayTitleHeaderViewModel: ViewModel {
    private(set) var title: String?
    
    init(_ name: GeneralSettings) {
        setTitle(name)
    }
    
    init(_ name: String) {
        setTitle(name)
    }
    
    private func setTitle(_ name: GeneralSettings) {
        switch name {
        case .account:
            self.title = "settings-sections-account".localized
        case .appPreferences:
            self.title = "settings-sections-appPreferences".localized
        case .support:
            self.title = "settings-sections-support".localized
        }
    }
    
    private func setTitle(_ name: String) {
        self.title = name.localized
    }
}

extension SingleGrayTitleHeaderViewModel: Hashable {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }
    
    static func == (
        lhs: SingleGrayTitleHeaderViewModel,
        rhs: SingleGrayTitleHeaderViewModel
    ) -> Bool {
        return lhs.title == rhs.title
    }
}
