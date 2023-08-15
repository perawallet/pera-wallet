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
//   TransactionTutorialView.swift

import MacaroonUIKit
import UIKit

final class TransactionTutorialView:
    View,
    ViewModelBindable {
    weak var delegate: TransactionTutorialViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var subtitleLabel = UILabel()
    private lazy var firstInstructionView = InstructionItemView()
    private lazy var secondInstructionView = InstructionItemView()
    private lazy var tapToMoreLabel = UILabel()
    private lazy var actionButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: TransactionTutorialViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addSubtitleLabel(theme)
        addFirstInstructionView(theme)
        addSecondInstructionView(theme)
        addTapToMoreLabel(theme)
        addActionButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        tapToMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(notifyDelegateToOpenMoreInfo)
            )
        )
        actionButton.addTarget(
            self,
            action: #selector(notifyDelegateToConfirmWarning),
            for: .touchUpInside
        )
    }

    func bindData(_ viewModel: TransactionTutorialViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleLabel)
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = nil
        }

        if let subtitle = viewModel?.subtitle {
            subtitle.load(in: subtitleLabel)
        } else {
            subtitleLabel.attributedText = nil
            subtitleLabel.text = nil
        }

        firstInstructionView.bindData(viewModel?.firstInstruction)
        secondInstructionView.bindData(viewModel?.secondInstruction)

        if let tapToMore = viewModel?.tapToMoreText {
            tapToMore.load(in: tapToMoreLabel)
        } else {
            tapToMoreLabel.attributedText = nil
            tapToMoreLabel.text = nil
        }
    }
}

extension TransactionTutorialView {
    @objc
    private func notifyDelegateToConfirmWarning() {
        delegate?.transactionTutorialViewDidConfirmTutorial(self)
    }

    @objc
    private func notifyDelegateToOpenMoreInfo() {
        delegate?.transactionTutorialViewDidOpenMoreInfo(self)
    }
}

extension TransactionTutorialView {
    private func addImageView(_ theme: TransactionTutorialViewTheme) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTitleLabel(_ theme: TransactionTutorialViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addSubtitleLabel(_ theme: TransactionTutorialViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addFirstInstructionView(_ theme: TransactionTutorialViewTheme) {
        firstInstructionView.customize(theme.instuctionViewTheme)

        addSubview(firstInstructionView)
        firstInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.firstInstructionTopPadding)
        }
    }

    private func addSecondInstructionView(_ theme: TransactionTutorialViewTheme) {
        secondInstructionView.customize(theme.instuctionViewTheme)

        addSubview(secondInstructionView)
        secondInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(firstInstructionView)
            $0.top.equalTo(firstInstructionView.snp.bottom).offset(theme.instructionSpacing)
        }

        secondInstructionView.addSeparator(
            theme.separator,
            padding: theme.spacingBetweenSecondInstructionViewAndSeparator
        )
    }

    private func addTapToMoreLabel(_ theme: TransactionTutorialViewTheme) {
        tapToMoreLabel.customizeAppearance(theme.tapToMore)

        addSubview(tapToMoreLabel)
        tapToMoreLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(secondInstructionView.snp.bottom).offset(theme.tapMoreLabelTopPadding)
        }
    }

    private func addActionButton(_ theme: TransactionTutorialViewTheme) {
        actionButton.contentEdgeInsets = UIEdgeInsets(theme.actionButtonContentEdgeInsets)
        actionButton.draw(corner: theme.actionButtonCorner)
        actionButton.customizeAppearance(theme.actionButton)
        
        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(tapToMoreLabel.snp.bottom).offset(theme.buttonTopInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomInset)
        }
    }
}

protocol TransactionTutorialViewDelegate: AnyObject {
    func transactionTutorialViewDidConfirmTutorial(_ transactionTutorialView: TransactionTutorialView)
    func transactionTutorialViewDidOpenMoreInfo(_ transactionTutorialView: TransactionTutorialView)
}
