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
//   PortfolioCalculationInfoView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class PortfolioCalculationInfoView: View {
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    
    func customize(
        _ theme: PortfolioCalculationInfoViewTheme
    ) {
        addTitle(theme)
        addBody(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension PortfolioCalculationInfoView {
    private func addTitle(
        _ theme: PortfolioCalculationInfoViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addBody(
        _ theme: PortfolioCalculationInfoViewTheme
    ) {
        bodyView.customizeAppearance(theme.body)
        
        addSubview(bodyView)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
