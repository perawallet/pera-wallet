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
//   AccountPortfolioView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountPortfolioView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = Label()
    private lazy var valueView = Label()

    func customize(
        _ theme: AccountPortfolioViewTheme
    ) {
        addTitle(theme)
        addValue(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: AccountPortfolioViewModel?
    ) {
        titleView.editText = viewModel?.title
        valueView.editText = viewModel?.value
    }
    
    class func calculatePreferredSize(
        _ viewModel: AccountPortfolioViewModel?,
        for theme: AccountPortfolioViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        
        let width =
            size.width -
            theme.contentHorizontalPaddings.leading -
            theme.contentHorizontalPaddings.trailing
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
            valueSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountPortfolioView {
    private func addTitle(
        _ theme: AccountPortfolioViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == theme.contentHorizontalPaddings.leading
            $0.trailing == theme.contentHorizontalPaddings.trailing
        }
    }
    
    private func addValue(
        _ theme: AccountPortfolioViewTheme
    ) {
        valueView.customizeAppearance(theme.value)
        
        addSubview(valueView)
        valueView.fitToIntrinsicSize()
        valueView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.leading == theme.contentHorizontalPaddings.leading
            $0.bottom == 0
            $0.trailing == theme.contentHorizontalPaddings.trailing
        }
    }
}
