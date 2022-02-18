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
//   AssetPortfolioItemView.swift

import UIKit
import MacaroonUIKit

final class AssetPortfolioItemView: View {

    private lazy var portfolioView = PortfolioValueView()

    func customize(_ theme: AssetPortfolioItemViewTheme) {
        addPortfolioView(theme)
    }

    func prepareLayout(_ layoutSheet: AssetPortfolioItemViewTheme) {}

    func customizeAppearance(_ styleSheet: AssetPortfolioItemViewTheme) {}
}

extension AssetPortfolioItemView {
    func addPortfolioView(_ theme: AssetPortfolioItemViewTheme) {
        addSubview(portfolioView)
        portfolioView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension AssetPortfolioItemView {
    func bindData(_ viewModel: PortfolioValueViewModel?) {
        portfolioView.bindData(viewModel)
    }
}

final class AssetPortfolioItemCell: BaseCollectionViewCell<AssetPortfolioItemView> {

    override func prepareLayout() {
        super.prepareLayout()
        contextView.customize(AssetPortfolioItemViewTheme())
    }

    func bindData(_ viewModel: PortfolioValueViewModel?) {
        contextView.bindData(viewModel)
    }
}
