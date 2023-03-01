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

//   AssetFilterItemView.swift

import UIKit
import MacaroonUIKit

final class AssetFilterItemView:
    View,
    ViewModelBindable,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .valueChanged: TargetActionInteraction(event: .valueChanged),
    ]

    var isOn: Bool {
        get { toggleView.isOn }
        set { toggleView.setOn(newValue, animated: true) }
    }

    var isEnabled: Bool {
        get { toggleView.isUserInteractionEnabled }
        set { updateUIForState(enabled: newValue) }
    }

    private lazy var titleView = Label()
    private lazy var descriptionView = Label()
    private lazy var toggleView = Toggle()

    private var theme: AssetFilterItemViewTheme?

    func customize(_ theme: AssetFilterItemViewTheme) {
        self.theme = theme

        addBackground(theme)
        addTitle(theme)
        addToggle(theme)
        addDescription(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: AssetFilterItemViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let description = viewModel?.description {
            description.load(in: descriptionView)
        } else {
            descriptionView.text = nil
            descriptionView.attributedText = nil
        }
    }
}

extension AssetFilterItemView {
    private func updateUIForState(enabled: Bool) {
        toggleView.isUserInteractionEnabled = enabled
        alpha = enabled ? 1 : 0.5
    }
}

extension AssetFilterItemView {
    private func addBackground(_ theme: AssetFilterItemViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addTitle(_ theme: AssetFilterItemViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.width <= self * theme.titleMaxWidthRatio
            $0.leading == 0
            $0.top == 0
        }
    }

    private func addToggle(_ theme: AssetFilterItemViewTheme) {
        toggleView.customize(theme.toggle)

        addSubview(toggleView)
        toggleView.fitToHorizontalIntrinsicSize()
        toggleView.snp.makeConstraints {
            $0.leading >= titleView.snp.trailing + theme.minimumHorizontalSpacing
            $0.trailing == 0
            $0.top == titleView
        }

        startPublishing(
            event: .valueChanged,
            for: toggleView
        )
    }

    private func addDescription(_ theme: AssetFilterItemViewTheme) {
        descriptionView.customizeAppearance(theme.description)

        addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.leading == 0
            $0.top == titleView.snp.bottom + theme.descriptionTopMargin
            $0.width == titleView
            $0.bottom == 0
        }
    }
}

extension AssetFilterItemView {
    enum Event {
        case valueChanged
    }
}
