// Copyright 2019 Algorand, Inc.

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
//   AlgoPriceAttributeView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgoPriceAttributeView:
    View,
    ViewModelBindable {
    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var loadingView = ShimmerView()
    
    func customize(
        _ theme: AlgoPriceAttributeViewTheme
    ) {
        addIcon(theme)
        addTitle(theme)
        addLoading(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: AlgoPriceAttributeViewModel?
    ) {
        iconView.image = viewModel?.icon
        titleView.editText = viewModel?.title
        loadingView.isHidden = viewModel != nil
    }
}

extension AlgoPriceAttributeView {
    private func addIcon(
        _ theme: AlgoPriceAttributeViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)
        
        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
        }
    }
    
    private func addTitle(
        _ theme: AlgoPriceAttributeViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addLoading(
        _ theme: AlgoPriceAttributeViewTheme
    ) {
        loadingView.draw(corner: theme.loadingCorner)
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
