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

//   CollectibleListInfoWithFilterView.swift

import UIKit
import MacaroonUIKit

final class CollectibleListInfoWithFilterView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .showFilterSelection: TargetActionInteraction()
    ]

    private lazy var infoView = Label()
    private lazy var filterActionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))

    func customize(
        _ theme: CollectibleListInfoWithFilterViewTheme
    ) {
        addBackground(theme)
        addInfo(theme)
        addFilter(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: CollectibleListInfoWithFilterViewModel?
    ) {
        infoView.editText = viewModel?.info
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleListInfoWithFilterViewModel?,
        for theme: CollectibleListInfoWithFilterViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width - theme.minimumHorizontalSpacing
        let infoSize = viewModel.info.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )

        let buttonHeight: LayoutMetric = 24
        let preferredHeight = max(infoSize.height, buttonHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleListInfoWithFilterView {
    func recustomizeAppearanceWhenFilterChanged(
        _ isFilterSelected: Bool
    ) {
        filterActionView.isSelected = isFilterSelected
    }
}

extension CollectibleListInfoWithFilterView {
    private func addBackground(
        _ theme: CollectibleListInfoWithFilterViewTheme
    ) {
        customizeBaseAppearance(
            backgroundColor: theme.backgroundColor
        )
    }

    private func addInfo(
        _ theme: CollectibleListInfoWithFilterViewTheme
    ) {
        infoView.customizeAppearance(theme.info)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.width >= self * theme.infoMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addFilter(
        _ theme: CollectibleListInfoWithFilterViewTheme
    ) {
        filterActionView.customizeAppearance(theme.filterAction)

        addSubview(filterActionView)
        filterActionView.fitToIntrinsicSize()
        filterActionView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= infoView.snp.trailing + theme.minimumHorizontalSpacing
            $0.trailing == 0
            $0.bottom == 0
        }

        startPublishing(
            event: .showFilterSelection,
            for: filterActionView
        )
    }
}

extension CollectibleListInfoWithFilterView {
    enum Event {
        case showFilterSelection
    }
}
