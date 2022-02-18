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
}

extension NoContentView {
    private func addContent(
        _ theme: NoContentViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.height <= snp.height

            $0.setHorizontalPaddings(theme.contentHorizontalPaddings)
            $0.setVerticalPaddings((theme.contentVerticalPadding, theme.contentVerticalPadding))
        }

        addResult(theme)
    }

    private func addResult(
        _ theme: NoContentViewTheme
    ) {
        resultView.customize(theme)

        contentView.addSubview(resultView)
        resultView.snp.makeConstraints {
            if let topInset = theme.resultTopInset {
                $0.setPaddings((topInset, 0, .noMetric, 0))
                return
            }

            $0.center == 0

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }
    }
}
