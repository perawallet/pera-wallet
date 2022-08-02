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
//   TitledTransactionAccountNameView.swift

import UIKit
import MacaroonUIKit
import SnapKit

final class TitledTransactionAccountNameView: View {
    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()

    var nameLabelImageLeadingConstraint: Constraint?
    var nameLabelLeadingConstraint: Constraint?

    func customize(_ theme: TitledTransactionAccountNameViewTheme) {
        addTitleLabel(theme)
        addImageView(theme)
        addNameLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension TitledTransactionAccountNameView {
    private func addTitleLabel(_ theme: TitledTransactionAccountNameViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }

    private func addImageView(_ theme: TitledTransactionAccountNameViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.detailLabelLeadingPadding)
            $0.centerY.equalToSuperview()
            $0.top.bottom.greaterThanOrEqualToSuperview().priority(.high)
            $0.fitToSize(theme.accountTheme.imageSize)
        }
    }

    private func addNameLabel(_ theme: TitledTransactionAccountNameViewTheme) {
        nameLabel.customizeAppearance(theme.accountTheme.titleLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()

            nameLabelImageLeadingConstraint = $0.leading.equalTo(imageView.snp.trailing)
                .offset(theme.nameLeadingInset)
                .constraint
            nameLabelLeadingConstraint = $0.leading.equalToSuperview()
                .inset(theme.detailLabelLeadingPadding)
                .priority(.high)
                .constraint
            $0.trailing.equalToSuperview()

            nameLabelLeadingConstraint?.deactivate()
        }
    }
}

extension TitledTransactionAccountNameView: ViewModelBindable {
    func bindData(_ viewModel: TitledTransactionAccountNameViewModel?) {
        if let title = viewModel?.title {
            titleLabel.text = title
        }

        if let accountNameViewModel = viewModel?.accountNameViewModel {
            imageView.load(from: accountNameViewModel.image)
            nameLabel.text = accountNameViewModel.name

            imageView.isHidden = accountNameViewModel.image == nil

            if accountNameViewModel.image == nil {
                nameLabelLeadingConstraint?.activate()
                nameLabelImageLeadingConstraint?.deactivate()
            } else {
                nameLabelLeadingConstraint?.deactivate()
                nameLabelImageLeadingConstraint?.activate()
            }

        }
    }
}

