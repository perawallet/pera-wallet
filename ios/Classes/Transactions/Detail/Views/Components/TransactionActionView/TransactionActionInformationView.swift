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

//   TransactionActionView.swift

import MacaroonUIKit
import SnapKit
import UIKit

final class TransactionActionInformationView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]
    private lazy var theme = TransactionActionInformationViewTheme()
    
    private lazy var titleLabel = Label()
    private lazy var rightContentView = UIView()
    private lazy var descriptionLabel = Label()
    private lazy var actionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    
    func customize(_ theme: TransactionActionInformationViewTheme) {
        self.theme = theme
        
        addTitle(theme)
        addRightContent(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension TransactionActionInformationView {
    private func addTitle(_ theme: TransactionActionInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        addSubview(titleLabel)
        titleLabel.fitToVerticalIntrinsicSize()
        titleLabel.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addRightContent(_ theme: TransactionActionInformationViewTheme) {
        addSubview(rightContentView)
        rightContentView.snp.makeConstraints {
            $0.height >= titleLabel
            $0.top == 0
            $0.leading == theme.descriptionLeadingPadding
            $0.bottom == 0
            $0.trailing == 0
        }

        titleLabel.snp.makeConstraints {
            $0.trailing == rightContentView.snp.leading - theme.minimumSpacingBetweenTitleAndItems
        }

        addDescription(theme)
        addAction(theme)
    }
    
    private func addDescription(_ theme: TransactionActionInformationViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)
        
        rightContentView.addSubview(descriptionLabel)
        descriptionLabel.contentEdgeInsets = (0, 0, theme.actionTopPadding, 0)
        descriptionLabel.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addAction(_ theme: TransactionActionInformationViewTheme) {
        actionView.customizeAppearance(theme.actionWithoutData)
        
        rightContentView.addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.top == descriptionLabel.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
        
        startPublishing(
            event: .performAction,
            for: actionView
        )
    }
}

extension TransactionActionInformationView: ViewModelBindable {
    func bindData(_ viewModel: TransactionActionInformationViewModel?) {
        guard let viewModel = viewModel else { return }
                
        if let title = viewModel.title {
            title.load(in: titleLabel)
        }
        
        if let description = viewModel.description.unwrapNonEmptyString() {
            description.load(in: descriptionLabel)
            actionView.recustomizeAppearance(theme.actionWithData)
        } else {
            descriptionLabel.clearText()
            actionView.recustomizeAppearance(theme.actionWithoutData)
        }
    }
}

extension TransactionActionInformationView {
    enum Event {
        case performAction
    }
}
