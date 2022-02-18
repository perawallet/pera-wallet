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
//   LoadingView.swift

import MacaroonUIKit
import UIKit

final class LoadingView:
    View,
    ListReusable {
    private lazy var loadingIndicator = ViewLoadingIndicator()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: LoadingViewTheme
    ) {
        addLoadingIndicator(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension LoadingView {
    func startAnimating() {
        loadingIndicator.startAnimating()
    }

    func stopAnimating() {
        loadingIndicator.stopAnimating()
    }
}

extension LoadingView {
    private func addLoadingIndicator(
        _ theme: LoadingViewTheme
    ) {
        loadingIndicator.applyStyle(theme.loadingIndicator)

        addSubview(loadingIndicator)
        loadingIndicator.fitToHorizontalIntrinsicSize()
        loadingIndicator.fitToVerticalIntrinsicSize()
        loadingIndicator.snp.makeConstraints {
            $0.center()
        }
    }
}
