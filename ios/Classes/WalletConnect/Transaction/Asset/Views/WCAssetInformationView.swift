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
//   WCAssetInformationView.swift

import UIKit
import MacaroonUIKit

final class WCAssetInformationView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction(),
    ]
    
    private lazy var titleLabel = UILabel()
    private lazy var assetView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))

    func customize(_ theme: WCAssetInformationViewTheme) {
        addTitle(theme)
        addAsset(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension WCAssetInformationView {
    private func addTitle(
        _ theme: WCAssetInformationViewTheme
    ) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
    }
    
    private func addAsset(
        _ theme: WCAssetInformationViewTheme
    ) {
        assetView.customizeAppearance(theme.asset)

        addSubview(assetView)
        assetView.fitToIntrinsicSize()
        assetView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.detailLabelLeadingPadding)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        startPublishing(
            event: .performAction,
            for: assetView
        )
    }
}

extension WCAssetInformationView: ViewModelBindable {
    func bindData(
        _ viewModel: WCAssetInformationViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        if let title = viewModel.title {
            title.load(in: titleLabel)
        } else {
            titleLabel.text = nil
            titleLabel.attributedText = nil
        }

        assetView.editTitle = viewModel.name
        assetView.setImage(viewModel.verificationTierIcon, for: .normal)

        if viewModel.verificationTierIcon == nil {
            assetView.layout = .none
            invalidateIntrinsicContentSize()
        }
    }
}

extension WCAssetInformationView {
    enum Event {
        case performAction
    }
}
