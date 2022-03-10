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
//  ToggleTitleView.swift

import UIKit
import MacaroonUIKit
import UIKit

final class ToggleTitleHeaderView: View {
    private lazy var titleLabel = UILabel()

    func customize(_ theme: ToggleTitleHeaderViewTheme) {
        addTitleLabel(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) { }
}

extension ToggleTitleHeaderView {
    private func addTitleLabel(_ theme: ToggleTitleHeaderViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().inset(theme.topPadding)
        }
    }
}
