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
//   AlgoStatisticsFooterView.swift

import MacaroonUIKit
import UIKit

final class AlgoStatisticsFooterView:
    View,
    ViewModelBindable {
    private lazy var titleLabel = UILabel()
    private lazy var dailyVolumeInfoView = AlgoStatisticsInfoView()
    private lazy var marketCapInfoView = AlgoStatisticsInfoView()
    private lazy var allTimeHighInfoView = AlgoStatisticsInfoView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AlgoStatisticsFooterViewTheme())
    }

    func customize(_ theme: AlgoStatisticsFooterViewTheme) {
        addTitleLabel(theme)
        addDailyVolumeInfoView(theme)
        addMarketCapInfoView(theme)
        addAllTimeHighInfoView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension AlgoStatisticsFooterView {
    private func addTitleLabel(_ theme: AlgoStatisticsFooterViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    private func addDailyVolumeInfoView(_ theme: AlgoStatisticsFooterViewTheme) {
        addSubview(dailyVolumeInfoView)
        dailyVolumeInfoView.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.topPadding
            $0.leading == 0
            $0.trailing == 0
        }

        dailyVolumeInfoView.addSeparator(theme.separator)
    }

    private func addMarketCapInfoView(_ theme: AlgoStatisticsFooterViewTheme) {
        addSubview(marketCapInfoView)
        marketCapInfoView.snp.makeConstraints {
            $0.top == dailyVolumeInfoView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }

        marketCapInfoView.addSeparator(theme.separator)
    }

    private func addAllTimeHighInfoView(_ theme: AlgoStatisticsFooterViewTheme) {
        addSubview(allTimeHighInfoView)
        allTimeHighInfoView.snp.makeConstraints {
            $0.top == marketCapInfoView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }
    }
}

extension AlgoStatisticsFooterView {
    func bindData(_ viewModel: AlgoStatisticsFooterViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        dailyVolumeInfoView.bindData(viewModel.dailyVolumeInfoViewModel)
        marketCapInfoView.bindData(viewModel.marketCapInfoViewModel)
        allTimeHighInfoView.bindData(viewModel.allTimeHighInfoViewModel)
    }
}
