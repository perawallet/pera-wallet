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
//   HomePortfolioItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomePortfolioItemView:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()
    private lazy var valueView = Label()
    private lazy var iconView = ImageView()
    
    func customize(
        _ theme: HomePortfolioItemViewTheme
    ) {
        addTitle(theme)
        addValue(theme)
        addIcon(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: HomePortfolioItemViewModel?
    ) {
        titleView.editText = viewModel?.title
        valueView.editText = viewModel?.value
        iconView.image = viewModel?.icon?.uiImage
    }
    
    class func calculatePreferredSize(
        _ viewModel: HomePortfolioItemViewModel?,
        for theme: HomePortfolioItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        
        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let valueSize = viewModel.value.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight =
            titleSize.height +
            theme.spacingBetweenTitleAndValue +
            max(valueSize.height, theme.valueMinHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension HomePortfolioItemView {
    private func addTitle(
        _ theme: HomePortfolioItemViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToHorizontalIntrinsicSize(
            hugging: .defaultHigh,
            compression: .required
        )
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addValue(
        _ theme: HomePortfolioItemViewTheme
    ) {
        valueView.customizeAppearance(theme.value)
        
        addSubview(valueView)
        valueView.fitToIntrinsicSize()
        valueView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.bottom == 0
            $0.trailing <= 0
            
            $0.greaterThanHeight(theme.valueMinHeight)
        }
    }
    
    private func addIcon(
        _ theme: HomePortfolioItemViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)
        
        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == valueView
            $0.leading == 0
            $0.trailing == valueView.snp.leading
        }
    }
}
