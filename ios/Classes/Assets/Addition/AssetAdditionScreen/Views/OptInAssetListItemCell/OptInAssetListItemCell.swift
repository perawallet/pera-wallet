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

//   OptInAssetListItemCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class OptInAssetListItemCell:
    CollectionCell<OptInAssetListItemView>,
    ViewModelBindable,
    UIInteractable {
    var accessory: OptInAssetListItemAccessory = .add {
        didSet { updateAccessoryIfNeeded(old: oldValue) }
    }

    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .add: TargetActionInteraction()
    ]

    override class var contextPaddings: LayoutPaddings {
        return theme.contextEdgeInsets
    }

    static let theme = OptInAssetListItemCellTheme()

    private lazy var accessoryView: LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator(indicator: "List/Accessories/loading".uiImage)
        return LoadingButton(loadingIndicator: loadingIndicator)
    }()

    override func prepareLayout() {
        addContext()
        addAccessory()
        addSeparator()
    }

    override func addContext() {
        let theme = Self.theme

        contextView.customize(theme.context)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.bottom == theme.contextEdgeInsets.bottom
        }
    }

    static func calculatePreferredSize(
        _ viewModel: OptInAssetListItemViewModel?,
        for theme: OptInAssetListItemCellTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let contextWidth =
            width -
            theme.contextEdgeInsets.leading -
            theme.spacingBetweenContextAndAccessory -
            theme.accessorySize.w -
            theme.contextEdgeInsets.trailing
        let maxContextSize = CGSize(width: contextWidth, height: .greatestFiniteMagnitude)
        let contextSize = ContextView.calculatePreferredSize(
            viewModel,
            for: theme.context,
            fittingIn: maxContextSize
        )
        let preferredHeight =
            theme.contextEdgeInsets.top +
            contextSize.height +
            theme.contextEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        accessory = .add
    }
}

extension OptInAssetListItemCell {
    private func addAccessory() {
        let theme = Self.theme

        contentView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.fitToSize(theme.accessorySize)
            $0.leading == contextView.snp.trailing + theme.spacingBetweenContextAndAccessory
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.centerY == 0
        }

        accessoryView.addTouch(
            target: self,
            action: #selector(publishAccessoryAction)
        )

        updateAccessory()
    }

    private func updateAccessoryIfNeeded(old: OptInAssetListItemAccessory) {
        if accessory != old {
            updateAccessory()
        }

        if accessory == .loading {
            accessoryView.startLoading()
        }
    }

    private func updateAccessory() {
        accessoryView.stopLoading()

        let theme = Self.theme

        let style: ButtonStyle
        let isInteractable: Bool
        switch accessory {
        case .add:
            style = theme.addAccessory
            isInteractable = true
        case .check:
            style = theme.checkAccessory
            isInteractable = false
        case .loading:
            style = theme.loadingAccessory
            isInteractable = false
        }

        accessoryView.customizeAppearance(style)
        accessoryView.isUserInteractionEnabled = isInteractable

        if accessory == .loading {
            accessoryView.startLoading()
        }
    }

    private func addSeparator() {
        separatorStyle = .single(Self.theme.separator)
    }
}

extension OptInAssetListItemCell {
    @objc
    private func publishAccessoryAction() {
        let accessoryInteraction: MacaroonUIKit.UIInteraction?
        switch accessory {
        case .add: accessoryInteraction = uiInteractions[.add]
        default: accessoryInteraction = nil
        }

        accessoryInteraction?.publish()
    }
}

extension OptInAssetListItemCell {
    enum Event {
        case add
    }
}
