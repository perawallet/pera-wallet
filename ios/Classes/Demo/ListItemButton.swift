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
//   ListItemButton.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ListItemButton:
    Control,
    ViewModelBindable {
    private lazy var iconView = ImageView()
    private lazy var contentView = UIView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    private lazy var accessoryView = ImageView()
    
    func customize(
        _ theme: ListItemButtonTheme
    ) {
        addIcon(theme)
        addContent(theme)
        addAccessory(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: ListItemButtonViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        titleView.editText = viewModel?.title
        subtitleView.editText = viewModel?.subtitle
        accessoryView.image = viewModel?.accessory?.uiImage
    }
}

extension ListItemButton {
    private func addIcon(
        _ theme: ListItemButtonTheme
    ) {
        iconView.customizeAppearance(theme.icon)
        
        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == 0
        }

        alignIcon(
            iconView,
            with: theme
        )
    }

    private func alignIcon(
        _ view: UIView,
        with theme: ListItemButtonTheme
    ) {
        switch theme.iconAlignment {
        case .centered:
            view.snp.makeConstraints {
                $0.centerY == 0
            }
        case let .aligned(top):
            view.snp.makeConstraints {
                $0.top == top + theme.contentVerticalPaddings.top
            }
        }
    }
    
    private func addContent(
        _ theme: ListItemButtonTheme
    ) {
        contentView.isUserInteractionEnabled = false
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentVerticalPaddings.top
            $0.leading == iconView.snp.trailing
            $0.bottom == theme.contentVerticalPaddings.bottom

            if let contentMinHeight = theme.contentMinHeight {
                $0.greaterThanHeight(contentMinHeight)
            }
        }
        
        addTitle(theme)
        addSubtitle(theme)
    }
    
    private func addTitle(
        _ theme: ListItemButtonTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addSubtitle(
        _ theme: ListItemButtonTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)
        
        contentView.addSubview(subtitleView)
        subtitleView.contentEdgeInsets = (theme.spacingBetweenTitleAndSubtitle, 0, 0, 0)
        subtitleView.fitToVerticalIntrinsicSize()
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addAccessory(
        _ theme: ListItemButtonTheme
    ) {
        accessoryView.customizeAppearance(theme.accessory)

        addSubview(accessoryView)
        accessoryView.contentEdgeInsets = theme.accessoryContentEdgeInsets
        accessoryView.fitToIntrinsicSize()
        accessoryView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == contentView.snp.trailing
            $0.trailing == 0
        }
    }
}

extension ListItemButton {
    enum IconViewAlignment {
        case centered
        case aligned(top: LayoutMetric)
    }
}
