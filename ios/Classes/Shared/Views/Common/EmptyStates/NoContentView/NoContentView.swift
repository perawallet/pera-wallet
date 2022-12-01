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
//   NoContentView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NoContentView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contentView = UIView()
    private lazy var resultView = ResultView()

    func customize(
        _ theme: NoContentViewTheme
    ) {
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: NoContentViewModel?
    ) {
        resultView.bindData(viewModel)
    }

    class func calculatePreferredSize(
        _ viewModel: NoContentViewModel?,
        for theme: NoContentViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let resultSize = ResultView.calculatePreferredSize(
            viewModel,
            for: theme,
            fittingIn: size
        )

        var additionalTopHeight: LayoutMetric = 0

        switch theme.resultAlignment {
        case let .aligned(top):
            additionalTopHeight = top
        default: break
        }

        let preferredHeight =
        resultSize.height +
        additionalTopHeight +
        theme.contentVerticalPaddings.top +
        theme.contentVerticalPaddings.bottom

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension NoContentView {
    private func addContent(
        _ theme: NoContentViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.height <= snp.height

            $0.setHorizontalPaddings(theme.contentHorizontalPaddings)
            $0.setVerticalPaddings(theme.contentVerticalPaddings)
        }

        addResult(theme)
    }

    private func addResult(
        _ theme: NoContentViewTheme
    ) {
        resultView.customize(theme)

        contentView.addSubview(resultView)
        resultView.snp.makeConstraints {
            $0.bottom <= 0
        }

        alignResult(resultView, for: theme.resultAlignment)
    }

    private func alignResult(
        _ view: UIView,
        for alignment: ResultViewAlignment
    ) {
        switch alignment {
        case .centered:
            view.snp.makeConstraints {
                $0.center == 0
                $0.setPaddings((.noMetric, 0, .noMetric, 0))
            }
        case let .aligned(top):
            view.snp.makeConstraints {
                $0.setPaddings((top, 0, .noMetric, 0))
            }
        }
    }
}

extension NoContentView {
    enum ResultViewAlignment {
        case centered
        case aligned(top: LayoutMetric)
    }
}
