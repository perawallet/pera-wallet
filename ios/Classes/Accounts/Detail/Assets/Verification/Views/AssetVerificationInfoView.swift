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

//   AssetVerificationInfoView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetVerificationInfoView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .learnMore: TargetActionInteraction()
    ]

    private lazy var assetVerificationBoxView = InfoBoxView()
    private lazy var learnMoreView = ListItemButton()

    func customize(
        _ theme: AssetVerificationInfoViewTheme
    ) {
        addAssetVerificationBox(theme)
        addLearnMore(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AssetVerificationInfoViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        assetVerificationBoxView.bindData(viewModel.assetVerification)
        learnMoreView.bindData(viewModel.learnMore)
    }

    class func calculatePreferredSize(
        _ viewModel: AssetVerificationInfoViewModel?,
        for theme: AssetVerificationInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let assetVerificationBoxSize = InfoBoxView.calculatePreferredSize(
            viewModel.assetVerification,
            for: theme.assetVerification,
            fittingIn: size
        )
        let learnMoreSize = viewModel.learnMore?.title.boundingSize(
            multiline: true,
            fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight = assetVerificationBoxSize.height +
            learnMoreSize.height +
            theme.spacingBetweenAssetVerificationAndLearnMore
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AssetVerificationInfoView {
    private func addAssetVerificationBox(
        _ theme: AssetVerificationInfoViewTheme
    ) {
        assetVerificationBoxView.customize(theme.assetVerification)

        addSubview(assetVerificationBoxView)
        assetVerificationBoxView.fitToVerticalIntrinsicSize()
        assetVerificationBoxView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

    }

    private func addLearnMore(
        _ theme: AssetVerificationInfoViewTheme
    ) {
        learnMoreView.customize(theme.learnMore)

        addSubview(learnMoreView)
        learnMoreView.fitToVerticalIntrinsicSize()
        learnMoreView.snp.makeConstraints {
            $0.greaterThanHeight(theme.learnMoreMinHeight)
            $0.top == assetVerificationBoxView.snp.bottom + theme.spacingBetweenAssetVerificationAndLearnMore
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        startPublishing(
            event: .learnMore,
            for: learnMoreView
        )
    }
}

extension AssetVerificationInfoView {
    enum Event {
        case learnMore
    }
}
