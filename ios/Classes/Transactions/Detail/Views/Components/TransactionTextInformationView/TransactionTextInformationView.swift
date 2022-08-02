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
//  TransactionTextInformationView.swift

import UIKit
import MacaroonUIKit

final class TransactionTextInformationView: View {
    private lazy var titleLabel = UILabel()
    private(set) lazy var detailLabel = UILabel()
    
    func customize(_ theme: TransactionTextInformationViewTheme) {
        addTitleLabel(theme)
        addDetailLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension TransactionTextInformationView {
    private func addTitleLabel(_ theme: TransactionTextInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.bottom <= theme.contentPaddings.bottom
        }
    }

    private func addDetailLabel(_ theme: TransactionTextInformationViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading + theme.detailLabelLeadingPadding
            $0.bottom == theme.contentPaddings.bottom
            $0.trailing <= theme.contentPaddings.trailing
        }

        titleLabel.snp.makeConstraints {
            $0.trailing == detailLabel.snp.leading - theme.minimumSpacingBetweenTitleAndDetail
        }
    }
}

extension TransactionTextInformationView: ViewModelBindable {
    func bindData(_ viewModel: TransactionTextInformationViewModel?) {
        if let title = viewModel?.title {
            titleLabel.text = title
        }

        if let detail = viewModel?.detail {
            detailLabel.text = detail
        }
    }
}
