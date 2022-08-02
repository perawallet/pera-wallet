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

//   AppCallAssetPreviewViewStackView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AppCallAssetPreviewViewStackView:
    View,
    ViewModelBindable {
    weak var delegate: AppCallAssetPreviewViewStackViewDelegate?
    
    private lazy var contextView = VStackView()
    private lazy var showMoreActionView = MacaroonUIKit.Button()

    private var theme: AppCallAssetPreviewStackViewTheme?

    func customize(
        _ theme: AppCallAssetPreviewStackViewTheme
    ) {
        self.theme = theme

        addContext(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AppCallAssetPreviewViewStackViewModel?
    ) {
        guard let viewModel = viewModel,
              let theme = theme else {
            return
        }

        viewModel.assets?.forEach(addPreview)

        if viewModel.requiresShowMoreAction {
            addShowMoreAction(
                viewModel: viewModel,
                theme: theme
            )
            showMoreActionView.editTitle = viewModel.showMoreActionTitle
        }
    }
}

extension AppCallAssetPreviewViewStackView {
    private func addContext(
        _ theme: AppCallAssetPreviewStackViewTheme
    ) {
        contextView.alignment = .leading
        contextView.spacing = theme.spacing

        addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addPreview(
        _ viewModel: AppCallAssetPreviewViewModel
    ) {
        let previewView = AppCallAssetPreviewView()
        previewView.customize(AppCallAssetPreviewViewTheme())
        previewView.bindData(viewModel)

        contextView.addArrangedSubview(previewView)
    }

    private func addShowMoreAction(
        viewModel: AppCallAssetPreviewViewStackViewModel,
        theme: AppCallAssetPreviewStackViewTheme
    ) {
        showMoreActionView.customizeAppearance(theme.action)

        showMoreActionView.editTitle = viewModel.showMoreActionTitle

        let aCanvasView = MacaroonUIKit.BaseView()
        aCanvasView.addSubview(showMoreActionView)
        showMoreActionView.snp.makeConstraints {
            $0.top == theme.additionalSpacingBetweenActionAndAssets
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        showMoreActionView.addTouch(
            target: self,
            action: #selector(didTapShowMore)
        )

        contextView.addArrangedSubview(aCanvasView)
    }
}

extension AppCallAssetPreviewViewStackView {
    @objc
    private func didTapShowMore() {
        delegate?.appCallAssetPreviewViewStackViewDidTapShowMore(self)
    }
}

protocol AppCallAssetPreviewViewStackViewDelegate: AnyObject {
    func appCallAssetPreviewViewStackViewDidTapShowMore(
        _ view: AppCallAssetPreviewViewStackView
    )
}
