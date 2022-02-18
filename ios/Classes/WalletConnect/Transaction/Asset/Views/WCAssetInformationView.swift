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

final class WCAssetInformationView: View {
    private lazy var titleLabel = UILabel()
    private lazy var detailStackView = HStackView()
    private lazy var verifiedIcon = UIImageView()
    private lazy var assetLabel = UILabel()

    func customize(_ theme: WCAssetInformationViewTheme) {
        addTitleLabel(theme)
        addDetail(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension WCAssetInformationView {
    private func addTitleLabel(_ theme: WCAssetInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }
    
    private func addDetail(_ theme: WCAssetInformationViewTheme) {
        detailStackView.spacing = theme.spacing

        addSubview(detailStackView)
        detailStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.detailLabelLeadingPadding)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        verifiedIcon.customizeAppearance(theme.verifiedIcon)
        assetLabel.customizeAppearance(theme.asset)

        detailStackView.addArrangedSubview(verifiedIcon)
        detailStackView.addArrangedSubview(assetLabel)
    }
}

extension WCAssetInformationView: ViewModelBindable {
    func bindData(_ viewModel: WCAssetInformationViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        if let title = viewModel.title {
            titleLabel.text = title
        }

        if let asset = viewModel.asset {
            if let assetId = viewModel.assetId {
                assetLabel.text = "\(asset) \(assetId)"
            } else {
                assetLabel.text = asset
            }
        }


        if viewModel.isVerified {
            verifiedIcon.showViewInStack()
        } else {
            verifiedIcon.hideViewInStack()
        }
    }
}
