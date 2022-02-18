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
//   SettingsHeaderView.swift

import UIKit
import MacaroonUIKit

final class SingleGrayTitleHeaderView: View {
    private lazy var theme = SingleGrayTitleHeaderViewTheme()
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
    }
    
    func customize(_ theme: SingleGrayTitleHeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addTitle()
    }
    
    func customizeAppearance(_ styleSheet: StyleSheet) {}
    
    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension SingleGrayTitleHeaderView {
    private func addTitle() {
        titleLabel.customizeAppearance(theme.title)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension SingleGrayTitleHeaderView {
    func bindData(_ viewModel: SingleGrayTitleHeaderViewModel) {
        titleLabel.text = viewModel.title
    }
}
