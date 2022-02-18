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
//  LedgerTutorialInstructionView.swift

import UIKit
import MacaroonUIKit

final class LedgerTutorialInstructionView: View {
    private lazy var titleLabel = UILabel()
    private lazy var arrowImageView = UIImageView()
    
    func customize(_ theme: LedgerTutorialInstructionViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addArrowImageView(theme)
        addTitleLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension LedgerTutorialInstructionView {
    private func addArrowImageView(_ theme: LedgerTutorialInstructionViewTheme) {
        arrowImageView.customizeAppearance(theme.arrowImage)

        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.iconSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addTitleLabel(_ theme: LedgerTutorialInstructionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.horizontalInset)
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(theme.titleHorizontalInset)
        }
    }
}

extension LedgerTutorialInstructionView: ViewModelBindable {
    func bindData(_ viewModel: LedgerTutorialInstructionViewModel?) {
        titleLabel.text = viewModel?.title
    }
}
