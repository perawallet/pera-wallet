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

//   AssetPreviewWithActionView.swift

import UIKit
import MacaroonUIKit

final class AssetPreviewWithActionView:
    View,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: UIControlInteraction()
    ]
    
    private lazy var contentView = AssetPreviewView()
    private lazy var actionView = Button()
    
    func customize(
        _ theme: AssetPreviewWithActionViewTheme
    ) {
        addContent(theme)
        addAction(theme)
    }
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: AssetPreviewWithActionViewModel?
    ) {
        contentView.bindData(viewModel?.contentViewModel)
        actionView.setImage(viewModel?.actionIcon, for: .normal)
    }

    func prepareForReuse() {
        contentView.prepareForReuse()
        actionView.setImage(nil, for: .normal)
    }

    class func calculatePreferredSize(
        _ viewModel: AssetPreviewWithActionViewModel?,
        for theme: AssetPreviewWithActionViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        let contentHeight = AssetPreviewView.calculatePreferredSize(
            viewModel.contentViewModel,
            for: theme.content,
            fittingIn: CGSize((width - theme.actionIconSize.w, .greatestFiniteMagnitude))
        ).height

        let actionHeight = theme.actionIconSize.h
        let preferredHeight = max(contentHeight, actionHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AssetPreviewWithActionView {
    private func addContent(
        _ theme: AssetPreviewWithActionViewTheme
    ) {
        contentView.customize(theme.content)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.setPaddings((0, 0, 0, .noMetric))
        }
    }

    private func addAction(
        _ theme: AssetPreviewWithActionViewTheme
    ) {
        actionView.draw(corner: theme.actionCorner)
        actionView.draw(shadow: theme.actionFirstShadow)
        actionView.draw(secondShadow: theme.actionSecondShadow)
        actionView.draw(thirdShadow: theme.actionThirdShadow)

        addSubview(actionView)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.fitToSize(theme.actionIconSize)
            $0.leading == contentView.snp.trailing + theme.minSpacingBetweenContentAndAction
            $0.trailing == 0
            $0.centerY == 0
        }

        startPublishing(
            event: .performAction,
            for: actionView
        )
    }
}

extension AssetPreviewWithActionView {
    enum Event {
        case performAction
    }
}
