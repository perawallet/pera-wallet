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

//   InfoBoxHeaderView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class InfoBoxHeaderView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var infoBoxView = InfoBoxView()
    private lazy var bodyView = Label()

    func customize(_ theme: InfoBoxHeaderViewTheme) {
        addInfoBox(theme)
        addBody(theme)
    }

    func bindData(_ viewModel: InfoBoxHeaderViewModel?) {
        if let infoBox = viewModel?.infoBox {
            infoBoxView.bindData(infoBox)
        } else {
            infoBoxView.prepareForReuse()
        }

        if let body = viewModel?.body {
            body.load(in: bodyView)
        } else {
            bodyView.prepareForReuse()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: InfoBoxHeaderViewModel?,
        for theme: InfoBoxHeaderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let infoBoxSize = InfoBoxView.calculatePreferredSize(
            viewModel.infoBox,
            for: theme.infoBox,
            fittingIn: size
        )
        let bodySize = viewModel.body?.boundingSize(
            multiline: true,
            fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
        ) ?? .zero

        let preferredHeight =
            infoBoxSize.height +
            theme.spacingBetweenInfoBoxAndBody +
            bodySize.height

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        infoBoxView.prepareForReuse()
        bodyView.prepareForReuse()
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension InfoBoxHeaderView {
    private func addInfoBox(_ theme: InfoBoxHeaderViewTheme) {
        infoBoxView.customize(theme.infoBox)

        addSubview(infoBoxView)
        infoBoxView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addBody(_ theme: InfoBoxHeaderViewTheme) {
        bodyView.customizeAppearance(theme.body)

        addSubview(bodyView)
        bodyView.contentEdgeInsets.top = theme.spacingBetweenInfoBoxAndBody
        bodyView.snp.makeConstraints {
            $0.top == infoBoxView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }
    }
}
