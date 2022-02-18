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
//  TransactionFilterOptionView.swift

import UIKit
import MacaroonUIKit

final class TransactionFilterOptionView: View {
    private lazy var dateImageView = UIImageView()
    private lazy var dateImageViewLabel = UILabel()
    private lazy var titleLabel = UILabel()
    private lazy var dateLabel = UILabel()
    private lazy var checkmarkImageView = UIImageView()

    func customize(_ theme: TransactionFilterOptionViewTheme) {
        addDateImageView(theme)
        addCheckmarkImageView(theme)
        addTitleLabel(theme)
        addDateLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension TransactionFilterOptionView {
    private func addDateImageView(_ theme: TransactionFilterOptionViewTheme) {
        addSubview(dateImageView)
        dateImageView.snp.makeConstraints {
            $0.fitToSize(theme.iconImageSize)
            $0.leading.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.dateImageVerticalInset)
        }

        addDateImageViewLabel(theme)
    }

    private func addDateImageViewLabel(_ theme: TransactionFilterOptionViewTheme) {
        dateImageViewLabel.customizeAppearance(theme.dateImageViewLabel)

        dateImageView.addSubview(dateImageViewLabel)
        dateImageViewLabel.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.dateImageLabelTopPadding)
        }
    }

    private func addCheckmarkImageView(_ theme: TransactionFilterOptionViewTheme) {
        checkmarkImageView.customizeAppearance(theme.checkmarkImage)

        addSubview(checkmarkImageView)
        checkmarkImageView.snp.makeConstraints {
            $0.fitToSize(theme.checkmarkImageSize)
            $0.trailing.centerY.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: TransactionFilterOptionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(dateImageView.snp.trailing).offset(theme.titleLabelLeadingInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.centerY.equalTo(dateImageView).priority(.medium)
            $0.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(theme.minimumHorizontalInset)
        }
    }
    
    private func addDateLabel(_ theme: TransactionFilterOptionViewTheme) {
        dateLabel.customizeAppearance(theme.date)

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(theme.minimumHorizontalInset)
        }
    }
}

extension TransactionFilterOptionView: ViewModelBindable {
    func bindData(_ viewModel: TransactionFilterOptionViewModel?) {
        titleLabel.text = viewModel?.title

        if let date = viewModel?.date {
            dateLabel.text = date
        } else {
            dateLabel.isHidden = true
        }

        if let dateImageText = viewModel?.dateImageText {
            dateImageViewLabel.text = dateImageText
        } else {
            dateImageViewLabel.isHidden = true
        }

        dateImageView.image = viewModel?.dateImage
        checkmarkImageView.isHidden = !((viewModel?.isSelected).falseIfNil)
    }
    
    func prepareForReuse() {
        titleLabel.text = nil
        dateLabel.text = nil
        dateImageViewLabel.text = nil
        dateImageView.image = nil
        dateLabel.isHidden = false
        dateImageViewLabel.isHidden = false
        checkmarkImageView.isHidden = true
    }
}
