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
//   LedgerAccountDetailSectionHeaderView.swift

import MacaroonUIKit
import UIKit

final class LedgerAccountDetailSectionHeaderView: View {
    private lazy var theme = LedgerAccountDetailSectionHeaderViewTheme()
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
    }
    
    func customize(_ theme: LedgerAccountDetailSectionHeaderViewTheme) {
        addTitleLabel(theme)
    }
    
    func prepareLayout(_ layoutSheet: LedgerAccountDetailSectionHeaderViewTheme) {}
    
    func customizeAppearance(_ styleSheet: LedgerAccountDetailSectionHeaderViewTheme) {}
}

extension LedgerAccountDetailSectionHeaderView {
    private func addTitleLabel(_ theme: LedgerAccountDetailSectionHeaderViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview()
        }
    }
}

extension LedgerAccountDetailSectionHeaderView: ViewModelBindable {
    func bindData(_ viewModel: LedgerAccountDetailSectionHeaderViewModel?) {
        titleLabel.text = viewModel?.headerTitle
    }
}
