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

//   CollectibleDetailAccountInformationView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDetailAccountInformationView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didLongPressTitle: GestureInteraction(gesture: .longPress)
    ]

    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var amountView = Label()

    private var isAmountLayoutLoaded = false

    private var theme: CollectibleDetailAccountInformationViewTheme?

    func customize(_ theme: CollectibleDetailAccountInformationViewTheme) {
        self.theme = theme

        addIcon(theme)
        addTitle(theme)
        addAmount(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: CollectibleDetailAccountInformationViewModel?) {
        iconView.image = viewModel?.icon?.uiImage

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }

        if let amount = viewModel?.amount {
            amount.load(in: amountView)
        } else {
            amountView.clearText()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleDetailAccountInformationViewModel?,
        for theme: CollectibleDetailAccountInformationViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconHeight = theme.iconSize.h
        let titleTextHeight = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((.greatestFiniteMagnitude, .greatestFiniteMagnitude))
        ).height ?? .zero
        let titleHeight =
            theme.titleContentEdgeInsets.top +
            titleTextHeight +
            theme.titleContentEdgeInsets.bottom
        let amountTextHeight = viewModel.amount?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ).height ?? .zero
        let amountHeight =
            theme.amountContentEdgeInsets.top +
            amountTextHeight +
            theme.amountContentEdgeInsets.bottom

        let contentHeight = max(max(iconHeight, titleHeight), amountHeight)
        let minCalculatedHeight = min(contentHeight.ceil(), size.height)
        return CGSize((size.width, minCalculatedHeight))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateUIWhenViewLayoutSubviews()
    }

    func prepareForReuse() {
        iconView.image = nil
        titleView.clearText()
        amountView.clearText()
    }

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        updateUIWhenUserInterfaceStyleDidChange()
    }
}

extension CollectibleDetailAccountInformationView {
    private func updateUIWhenViewLayoutSubviews() {
        updateAmountWhenViewLayoutSubviews()
    }

    private func updateAmountWhenViewLayoutSubviews() {
        if isAmountLayoutLoaded {
            return
        }

        if amountView.bounds.isEmpty {
            return
        }

        let amountViewRadius = amountView.frame.height / 2
        let amountViewCorner = Corner(radius: amountViewRadius.ceil())
        amountView.draw(corner: amountViewCorner)

        isAmountLayoutLoaded = true
    }
}

extension CollectibleDetailAccountInformationView {
    private func updateUIWhenUserInterfaceStyleDidChange() {
        updateAmountWhenUserInterfaceStyleDidChange()
    }

    private func updateAmountWhenUserInterfaceStyleDidChange() {
        if let theme {
            amountView.draw(border: theme.amountBorder)
        }
    }
}

extension CollectibleDetailAccountInformationView {
    private func addIcon(
        _ theme: CollectibleDetailAccountInformationViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addTitle(
        _ theme: CollectibleDetailAccountInformationViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.contentEdgeInsets = theme.titleContentEdgeInsets
        titleView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndTitle
            $0.bottom <= 0
            $0.centerY == 0
        }

        startPublishing(
            event: .didLongPressTitle,
            for: titleView
        )
    }

    private func addAmount(
        _ theme: CollectibleDetailAccountInformationViewTheme
    ) {
        amountView.customizeAppearance(theme.amount)
        amountView.draw(border: theme.amountBorder)

        addSubview(amountView)
        amountView.fitToHorizontalIntrinsicSize()
        amountView.contentEdgeInsets = theme.amountContentEdgeInsets
        amountView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == titleView.snp.trailing + theme.spacingBetweenTitleAndAmount
            $0.bottom <= 0
            $0.trailing <= 0
            $0.centerY == 0
        }
    }
}

extension CollectibleDetailAccountInformationView {
    enum Event {
        case didLongPressTitle
    }
}
