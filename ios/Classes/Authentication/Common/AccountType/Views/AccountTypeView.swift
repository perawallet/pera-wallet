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
//  AccountTypeView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class AccountTypeView: Control {
    private lazy var theme = AccountTypeViewTheme()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()

    private lazy var badgeView = Label()

    func customize(_ theme: AccountTypeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addBadge(theme)
        addDetailLabel(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AccountTypeView {
    private func addImageView(_ theme: AccountTypeViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.iconSize)
            $0.centerY.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: AccountTypeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
        }

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func addDetailLabel(_ theme: AccountTypeViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.minimumInset)
            $0.bottom.equalToSuperview().offset(-theme.verticalInset)
        }

        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func addBadge(_ theme: AccountTypeViewTheme) {
        badgeView.customizeAppearance(theme.badge)
        badgeView.draw(corner: theme.badgeCorner)
        badgeView.contentEdgeInsets = theme.badgeContentEdgeInsets

        addSubview(badgeView)
        badgeView.fitToHorizontalIntrinsicSize()
        badgeView.snp.makeConstraints {
            $0.centerY == titleLabel
            $0.leading == titleLabel.snp.trailing + theme.badgeHorizontalEdgeInsets.leading
            $0.trailing <= theme.badgeHorizontalEdgeInsets.trailing
        }

        badgeView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}

extension AccountTypeView: ViewModelBindable {
    func bindData(_ viewModel: AccountTypeViewModel?) {
        imageView.image = viewModel?.image
        titleLabel.editText = viewModel?.title
        detailLabel.editText = viewModel?.detail
        badgeView.text = viewModel?.badge
    }
}
