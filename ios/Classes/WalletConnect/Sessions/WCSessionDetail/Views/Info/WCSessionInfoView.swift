// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionInfoView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCSessionInfoView:
    TripleShadowView,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performCheckSessionStatus: TargetActionInteraction()
    ]

    private lazy var contextView = VStackView()
    private lazy var connectionDateInfoView = SecondaryListItemView()
    private lazy var expirationDateInfoView = SecondaryListItemView()
    private lazy var sessionStatusInfoView = SecondaryListItemView()

    private var theme: WCSessionInfoViewTheme?

    func customize(_ theme: WCSessionInfoViewTheme) {
        self.theme = theme

        drawAppearance(shadow: theme.firstShadow)
        drawAppearance(secondShadow: theme.secondShadow)
        drawAppearance(thirdShadow: theme.thirdShadow)

        addContext(theme)
    }

    func bindData(_ viewModel: WCSessionInfoViewModel?) {
        if let connectionDate = viewModel?.connectionDate {
            if !connectionDateInfoView.isDescendant(of: contextView) {
                addConnectionDate()
            }

            bindConnectionDate(connectionDate)
        }

        if let expirationDate = viewModel?.expirationDate {
            if !expirationDateInfoView.isDescendant(of: contextView) {
                addExpirationDate()
            }

            bindExpirationDate(expirationDate)
        }

        if let sessionStatus = viewModel?.sessionStatus {
            if !sessionStatusInfoView.isDescendant(of: contextView) {
                addSessionStatus()
            }

            bindSessionStatus(sessionStatus)
        }
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionInfoViewModel?,
        for theme: WCSessionInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let contextWidth =
            width -
            theme.contextEdgeInsets.leading -
            theme.contextEdgeInsets.trailing
        let maxContextSize = CGSize((contextWidth, .greatestFiniteMagnitude))

        let itemHeights = [
            viewModel.connectionDate,
            viewModel.expirationDate,
            viewModel.sessionStatus
        ].compactMap(calculateItemPreferredHeight)

        let contentHeight = itemHeights.reduce(0, +)
        let totalItemSpacingHeight = theme.spacingBetweenItems * CGFloat(itemHeights.count - 1)

        let preferredHeight =
            theme.contextEdgeInsets.top +
            contentHeight +
            totalItemSpacingHeight +
            theme.contextEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))

        func calculateItemPreferredHeight(_ viewModel: SecondaryListItemViewModel?) -> CGFloat? {
            guard let viewModel = viewModel else { return nil }

            let size = Self.calculatePreferredSize(
                viewModel,
                for: theme.item,
                fittingIn: maxContextSize
            )
            return max(size.height, theme.itemMinHeight)
        }
    }

    private static func calculatePreferredSize(
        _ viewModel: SecondaryListItemViewModel?,
        for layoutSheet: SecondaryListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))

        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let accessoryTitleSize = viewModel.accessory?.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero

        let preferredHeight = max(titleSize.height, accessoryTitleSize.height)
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension WCSessionInfoView {
    private func addContext(_ theme: WCSessionInfoViewTheme) {
        contextView.distribution = .fill
        contextView.alignment = .fill
        contextView.spacing = theme.spacingBetweenItems
        addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.bottom == theme.contextEdgeInsets.bottom
            $0.trailing == theme.contextEdgeInsets.trailing
        }
    }

    private func addConnectionDate() {
        guard let theme else { return }

        connectionDateInfoView.customize(theme.item)

        contextView.addArrangedSubview(connectionDateInfoView)

        connectionDateInfoView.snp.makeConstraints {
            $0.greaterThanHeight(theme.itemMinHeight)
        }
    }

    private func addExpirationDate() {
        guard let theme else { return }

        expirationDateInfoView.customize(theme.item)

        contextView.addArrangedSubview(expirationDateInfoView)

        expirationDateInfoView.snp.makeConstraints {
            $0.greaterThanHeight(theme.itemMinHeight)
        }
    }

    private func addSessionStatus() {
        guard let theme else { return }

        sessionStatusInfoView.customize(theme.item)

        contextView.addArrangedSubview(sessionStatusInfoView)

        sessionStatusInfoView.snp.makeConstraints {
            $0.greaterThanHeight(theme.itemMinHeight)
        }

        sessionStatusInfoView.startObserving(event: .didTapAccessory) {
            [unowned self] in
            let uiInteraction = uiInteractions[.performCheckSessionStatus]
            uiInteraction?.publish()
        }
    }
}

extension WCSessionInfoView {
    private func bindConnectionDate(_ viewModel: WCSessionConnectionDateSecondaryListItemViewModel?) {
        connectionDateInfoView.bindData(viewModel)
    }

    private func bindExpirationDate(_ viewModel: WCSessionExpirationDateSecondaryListItemViewModel?) {
        expirationDateInfoView.bindData(viewModel)
    }

    func bindSessionStatus(_ viewModel: WCSessionStatusSecondaryListItemViewModel?) {
        sessionStatusInfoView.isUserInteractionEnabled = viewModel?.isInteractable ?? true

        sessionStatusInfoView.bindData(viewModel)
    }
}

extension WCSessionInfoView {
    enum Event {
        case performCheckSessionStatus
    }
}
