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
//  PinLimitView.swift

import UIKit
import MacaroonUIKit

final class PinLimitView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .resetAllData: TargetActionInteraction(),
    ]

    private lazy var lockImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()
    private lazy var tryAgainLabel = UILabel()
    private lazy var counterLabel = UILabel()
    private lazy var resetButton = MacaroonUIKit.Button()

    func customize(_ theme: PinLimitViewTheme) {
        addLockImageView(theme)
        addTitleLabel(theme)
        addSubtitleLabel(theme)
        addTryAgainLabel(theme)
        addCounterLabel(theme)
        addResetButton(theme)
    }

    func bindData(_ viewModel: PinLimitViewModel?) {
        counterLabel.editText = viewModel?.remainingTime
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension PinLimitView {
    private func addLockImageView(_ theme: PinLimitViewTheme) {
        lockImageView.customizeAppearance(theme.lockIcon)

        addSubview(lockImageView)
        lockImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.imageViewTopInset)
        }
    }

    private func addTitleLabel(_ theme: PinLimitViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(lockImageView.snp.bottom).offset(theme.titleLabelTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSubtitleLabel(_ theme: PinLimitViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.subtitleLabelTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        subtitleLabel.addSeparator(theme.separator, padding: theme.spacingBetweenSubtitleAndSeparator)
    }
    
    private func addTryAgainLabel(_ theme: PinLimitViewTheme) {
        tryAgainLabel.customizeAppearance(theme.tryAgain)

        addSubview(tryAgainLabel)
        tryAgainLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.tryAgainLabelTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addCounterLabel(_ theme: PinLimitViewTheme) {
        counterLabel.customizeAppearance(theme.counter)

        addSubview(counterLabel)
        counterLabel.snp.makeConstraints {
            $0.top.equalTo(tryAgainLabel.snp.bottom).offset(theme.counterTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addResetButton(_ theme: PinLimitViewTheme) {
        resetButton.contentEdgeInsets = UIEdgeInsets(theme.resetButtonContentEdgeInsets)
        resetButton.draw(corner: theme.resetButtonCorner)
        resetButton.customizeAppearance(theme.resetButton)

        addSubview(resetButton)
        resetButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(theme.bottomPadding + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
        
        startPublishing(
            event: .resetAllData,
            for: resetButton
        )
    }
}

extension PinLimitView {
    enum Event {
        case resetAllData
    }
}
