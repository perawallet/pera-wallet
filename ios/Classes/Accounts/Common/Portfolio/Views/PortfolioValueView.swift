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
//   PortfolioValueView.swift

import MacaroonUIKit
import UIKit

final class PortfolioValueView: View {
    lazy var handlers = Handlers()

    private lazy var titleButton = Button(.imageAtRight(spacing: 8))
    private lazy var portfolioValueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
        customize(PortfolioValueViewTheme())
    }

    func setListeners() {
        titleButton.addTarget(self, action: #selector(didTapTitle), for: .touchUpInside)
    }

    func customize(_ theme: PortfolioValueViewTheme) {
        addTitleButton(theme)
        addPortfolioValueLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension PortfolioValueView {
    private func addTitleButton(_ theme: PortfolioValueViewTheme) {
        titleButton.customizeAppearance(theme.title)

        addSubview(titleButton)
        titleButton.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
        }
    }

    private func addPortfolioValueLabel(_ theme: PortfolioValueViewTheme) {
        portfolioValueLabel.customizeAppearance(theme.value)

        addSubview(portfolioValueLabel)
        portfolioValueLabel.snp.makeConstraints {
            $0.top.equalTo(titleButton.snp.bottom).offset(theme.verticalInset)
            $0.leading.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension PortfolioValueView {
    @objc
    private func didTapTitle() {
        handlers.didTapTitle?()
    }
}

extension PortfolioValueView: ViewModelBindable {
    func bindData(_ viewModel: PortfolioValueViewModel?) {
        titleButton.editTitle = viewModel?.title
        titleButton.mc_setImage(viewModel?.icon, for: .normal)
        titleButton.setTitleColor(viewModel?.titleColor, for: .normal)
        titleButton.tintColor = viewModel?.titleColor
        portfolioValueLabel.editText = viewModel?.value
    }
}

extension PortfolioValueView {
    struct Handlers {
        var didTapTitle: EmptyHandler?
    }
}
