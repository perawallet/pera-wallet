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

//   AppCallTransactionAssetInformationView.swift

import UIKit
import MacaroonUIKit

final class AppCallTransactionAssetInformationView:
    View,
    ViewModelBindable,
    AppCallAssetPreviewViewStackViewDelegate {
    weak var delegate: AppCallTransactionAssetInformationViewDelegate?

    private lazy var titleView = Label()
    private lazy var assetInfoView = AppCallAssetPreviewViewStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        linkInteractors()
    }

    func customize(
        _ theme: AppCallTransactionAssetInformationViewTheme
    ) {
        addTitleLabel(theme)
        addAssetInfo(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: AppCallTransactionAssetInformationViewModel?
    ) {
        titleView.editText = viewModel?.title
        assetInfoView.bindData(viewModel?.assetInfo)
    }

    func linkInteractors() {
        assetInfoView.delegate = self
    }

    func appCallAssetPreviewViewStackViewDidTapShowMore(
        _ view: AppCallAssetPreviewViewStackView
    ) {
        delegate?.appCallTransactionAssetInformationViewDidTapShowMore(self)
    }
}

extension AppCallTransactionAssetInformationView {
    private func addTitleLabel(
        _ theme: AppCallTransactionAssetInformationViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.bottom <= theme.contentPaddings.bottom
        }
    }

    private func addAssetInfo(
        _ theme: AppCallTransactionAssetInformationViewTheme
    ) {
        assetInfoView.customize(theme.assetInfo)

        addSubview(assetInfoView)
        assetInfoView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading + theme.assetInfoLeadingPadding
            $0.bottom == theme.contentPaddings.bottom
            $0.trailing <= theme.contentPaddings.trailing
        }

        titleView.snp.makeConstraints {
            $0.trailing == assetInfoView.snp.leading - theme.minimumSpacingBetweenTitleAndAssetInfo
        }
    }
}

protocol AppCallTransactionAssetInformationViewDelegate: AnyObject {
    func appCallTransactionAssetInformationViewDidTapShowMore(
        _ view: AppCallTransactionAssetInformationView
    )
}
