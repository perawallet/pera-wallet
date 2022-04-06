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
//   PendingAssetImageView.swift

import MacaroonUIKit
import UIKit

final class PendingAssetImageView: View {
    private lazy var borderImageView = ImageView()
    private lazy var loadingIndicator = ViewLoadingIndicator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(PendingAssetImageViewTheme())
    }

    private func customize(_ theme: PendingAssetImageViewTheme) {
        addBorderImage(theme)
        addLoadingIndicator(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension PendingAssetImageView {
    private func addBorderImage(_ theme: PendingAssetImageViewTheme) {
        borderImageView.customizeAppearance(theme.borderImage)

        addSubview(borderImageView)
        borderImageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addLoadingIndicator(_ theme: PendingAssetImageViewTheme) {
        loadingIndicator.applyStyle(theme.indicator)

        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints {
            $0.fitToSize(theme.indicatorSize)
            $0.center.equalToSuperview()
        }
    }
}

extension PendingAssetImageView {
    func startLoading() {
        loadingIndicator.startAnimating()
    }

    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
}

extension PendingAssetImageView {
    func prepareForReuse() {
        stopLoading()
    }
}
