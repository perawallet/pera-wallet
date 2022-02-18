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
//   AlgoStatisticsInfoView.swift

import MacaroonUIKit
import UIKit

final class AlgoStatisticsInfoView: View {
    private lazy var titleLabel = UILabel()
    private lazy var valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AlgoStatisticsInfoViewTheme())
    }

    func customize(_ theme: AlgoStatisticsInfoViewTheme) {
        addTitleLabel(theme)
        addValueLabel(theme)
    }

    func prepareLayout(_ layoutSheet: AlgoStatisticsInfoViewTheme) {}

    func customizeAppearance(_ styleSheet: AlgoStatisticsInfoViewTheme) {}
}

extension AlgoStatisticsInfoView {
    func addTitleLabel(_ theme: AlgoStatisticsInfoViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
    }

    func addValueLabel(_ theme: AlgoStatisticsInfoViewTheme) {
        valueLabel.customizeAppearance(theme.value)

        addSubview(valueLabel)
        valueLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalPadding)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(theme.minimumHorizontalPadding)
            $0.trailing.equalToSuperview()
        }
    }
}

extension AlgoStatisticsInfoView: ViewModelBindable {
    func bindData(_ viewModel: AlgoStatisticsInfoViewModel?) {
        valueLabel.text = viewModel?.value
        titleLabel.text = viewModel?.title
    }
}
