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
//   ScreenLoadingIndicator.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ScreenLoadingIndicator:
    View,
    MacaroonUIKit.LoadingIndicator {
    var title: String? {
        get { titleView.text }
        set { titleView.text = newValue }
    }

    var attributedTitle: NSAttributedString? {
        get { titleView.attributedText }
        set { titleView.attributedText = newValue }
    }

    var isAnimating: Bool {
        return indicatorView.isAnimating
    }

    private lazy var contentView = UIView()
    private lazy var indicatorView = ViewLoadingIndicator()
    private lazy var titleView = Label()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        customize(ScreenLoadingIndicatorTheme())
    }

    func customize(
        _ theme: ScreenLoadingIndicatorTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension ScreenLoadingIndicator {
    func startAnimating() {
        indicatorView.startAnimating()
    }

    func stopAnimating() {
        indicatorView.stopAnimating()
    }
}

extension ScreenLoadingIndicator {
    private func addBackground(
        _ theme: ScreenLoadingIndicatorTheme
    ) {
        drawAppearance(shadow: theme.background)
    }

    private func addContent(
        _ theme: ScreenLoadingIndicatorTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= contentView.snp.height

            $0.setPaddings(theme.contentEdgeInsets)
        }

        addIndicator(theme)
        addTitle(theme)
    }

    private func addIndicator(
        _ theme: ScreenLoadingIndicatorTheme
    ) {
        indicatorView.applyStyle(theme.indicator)

        contentView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.centerHorizontally(
                verticalPaddings: (0, .noMetric)
            )
        }
    }

    private func addTitle(
        _ theme: ScreenLoadingIndicatorTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.contentEdgeInsets = (theme.titleTopMargin, 0, 0, 0)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == indicatorView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}
