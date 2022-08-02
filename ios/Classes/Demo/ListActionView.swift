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
//   ListActionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ListActionView:
    Control,
    ViewModelBindable {
    private lazy var iconView = ImageView()
    private lazy var contentView = UIView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    
    func customize(
        _ theme: ListActionViewTheme
    ) {
        addIcon(theme)
        addContent(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: ListActionViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        titleView.editText = viewModel?.title
        subtitleView.editText = viewModel?.subtitle
    }
}

extension ListActionView {
    private func addIcon(
        _ theme: ListActionViewTheme
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
        with theme: ListActionViewTheme
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
        _ theme: ListActionViewTheme
    ) {
        contentView.isUserInteractionEnabled = false
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.centerY == 0
            $0.top == 0 + theme.contentVerticalPaddings.top
            $0.leading == iconView.snp.trailing
            $0.bottom == 0 + theme.contentVerticalPaddings.bottom
            $0.trailing == 0
            
            $0.greaterThanHeight(theme.contentMinHeight)
        }
        
        addTitle(theme)
        addSubtitle(theme)
    }
    
    private func addTitle(
        _ theme: ListActionViewTheme
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
        _ theme: ListActionViewTheme
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
}

extension ListActionView {
    enum IconViewAlignment {
        case centered
        case aligned(top: LayoutMetric)
    }
}
