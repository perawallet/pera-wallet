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
//   WCSingleTransactionRequestMiddleView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSingleTransactionRequestMiddleView: BaseView {
    private lazy var verticalStack = VStackView()
    private lazy var horizontalStack = HStackView()

    private lazy var icon = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()

    private lazy var theme = WCSingleTransactionRequestMiddleViewTheme()

    override func configureAppearance() {
        super.configureAppearance()

        icon.customizeAppearance(theme.checkmarkIcon)
        titleLabel.customizeAppearance(theme.titleLabel)
        subtitleLabel.customizeAppearance(theme.subtitleLabel)

        verticalStack.alignment = .center
        verticalStack.distribution = .equalSpacing
        verticalStack.spacing = theme.verticalStackViewSpacing
    }

    override func prepareLayout() {
        super.prepareLayout()

        addStackViews()
        addItems()
    }
}

extension WCSingleTransactionRequestMiddleView {
    private func addStackViews() {
        addSubview(verticalStack)
        verticalStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        verticalStack.addArrangedSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.height.equalTo(theme.horizontalStackViewHeight)
        }

        horizontalStack.distribution = .equalSpacing
        horizontalStack.alignment = .center
        horizontalStack.spacing = theme.horizontalStackViewSpacing
        
    }

    private func addItems() {
        horizontalStack.addArrangedSubview(icon)
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(theme.iconHeight)
        }
        horizontalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(subtitleLabel)
    }
}

extension WCSingleTransactionRequestMiddleView {
    func bind(_ viewModel: WCSingleTransactionRequestMiddleViewModel?) {
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.subtitle
        icon.isHidden = viewModel?.isAssetIconHidden ?? true
    }
}
