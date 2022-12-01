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
//   AccountSelectionView.swift

import UIKit
import MacaroonUIKit
import SnapKit

final class AccountSelectionView: View {
    private lazy var typeImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var checkmarkImageView = UIImageView()

    struct Configuration {
        var showsArrowImageView = false
    }

    var configuration = Configuration()

    func customize(_ theme: AccountSelectionViewTheme) {
        addTypeImageView(theme)
        if configuration.showsArrowImageView { addCheckmarkImageView(theme) }
        addNameLabel(theme)
        addDetailLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) { }

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension AccountSelectionView {
    private func addTypeImageView(_ theme: AccountSelectionViewTheme) {
        addSubview(typeImageView)
        typeImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
        }
    }

    private func addCheckmarkImageView(_ theme: AccountSelectionViewTheme) {
        checkmarkImageView.customizeAppearance(theme.checkmarkImage)

        addSubview(checkmarkImageView)
        checkmarkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.checkmarkImageSize)
            $0.trailing.equalToSuperview()
        }
    }

    private func addNameLabel(_ theme: AccountSelectionViewTheme) {
        nameLabel.customizeAppearance(theme.title)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(typeImageView.snp.trailing).offset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.centerY.equalTo(typeImageView).priority(.low)
            makeTrailingConstraint($0, offset: -theme.horizontalInset)
        }
    }

    private func addDetailLabel(_ theme: AccountSelectionViewTheme) {
        detailLabel.customizeAppearance(theme.secondaryTitle)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
            makeTrailingConstraint($0, offset: -theme.horizontalInset)
        }
    }
}

extension AccountSelectionView {
    func makeTrailingConstraint(_ constraintMaker: ConstraintMaker, offset: LayoutMetric) {
        if configuration.showsArrowImageView {
            constraintMaker.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(offset)
        } else {
            constraintMaker.trailing.lessThanOrEqualToSuperview().offset(offset)
        }
    }
}

extension AccountSelectionView: ViewModelBindable {
    func bindData(_ viewModel: AccountCellViewModel?) {
        typeImageView.image = viewModel?.accountImageTypeImage
        nameLabel.text = viewModel?.name
        detailLabel.text = viewModel?.detail ?? viewModel?.attributedDetail?.string

        if configuration.showsArrowImageView {
            checkmarkImageView.isHidden = !((viewModel?.isSelected).falseIfNil)
        }
    }

    func unselect() {
        checkmarkImageView.isHidden = true
    }
}
