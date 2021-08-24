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
//   ChartTimeFrameSelectionView.swift

import UIKit

class ChartTimeFrameSelectionView: BaseView {

    weak var delegate: ChartTimeFrameSelectionViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 16.0
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var hourlyButton = ChartTimeFrameButton(title: "chart-time-selection-hourly".localized)

    private lazy var dailyButton = ChartTimeFrameButton(title: "chart-time-selection-daily".localized)

    private lazy var weeklyButton = ChartTimeFrameButton(title: "chart-time-selection-weekly".localized)

    private lazy var monthlyButton = ChartTimeFrameButton(title: "chart-time-selection-monthly".localized)

    private lazy var yearlyButton = ChartTimeFrameButton(title: "chart-time-selection-yearly".localized)

    private lazy var allTimeButton = ChartTimeFrameButton(title: "chart-time-selection-all".localized)

    override func configureAppearance() {
        backgroundColor = .clear
        hourlyButton.isSelected = true
    }

    override func prepareLayout() {
        setupStackViewLayout()
    }

    override func setListeners() {
        hourlyButton.addTarget(self, action: #selector(notifyDelegateToSelectHourlyTimeInterval), for: .touchUpInside)
        dailyButton.addTarget(self, action: #selector(notifyDelegateToSelectDailyTimeInterval), for: .touchUpInside)
        weeklyButton.addTarget(self, action: #selector(notifyDelegateToSelectWeeklyTimeInterval), for: .touchUpInside)
        monthlyButton.addTarget(self, action: #selector(notifyDelegateToSelectMonthlyTimeInterval), for: .touchUpInside)
        yearlyButton.addTarget(self, action: #selector(notifyDelegateToSelectYearlyTimeInterval), for: .touchUpInside)
        allTimeButton.addTarget(self, action: #selector(notifyDelegateToSelectAllTimeInterval), for: .touchUpInside)
    }
}

extension ChartTimeFrameSelectionView {
    private func setupStackViewLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(hourlyButton)
        stackView.addArrangedSubview(dailyButton)
        stackView.addArrangedSubview(weeklyButton)
        stackView.addArrangedSubview(monthlyButton)
        stackView.addArrangedSubview(yearlyButton)
        stackView.addArrangedSubview(allTimeButton)
    }
}

extension ChartTimeFrameSelectionView {
    @objc
    private func notifyDelegateToSelectHourlyTimeInterval() {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: .hourly)
        hourlyButton.isSelected = true
    }

    @objc
    private func notifyDelegateToSelectDailyTimeInterval() {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: .daily)
        dailyButton.isSelected = true
    }

    @objc
    private func notifyDelegateToSelectWeeklyTimeInterval() {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: .weekly)
        weeklyButton.isSelected = true
    }

    @objc
    private func notifyDelegateToSelectMonthlyTimeInterval() {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: .monthly)
        monthlyButton.isSelected = true
    }

    @objc
    private func notifyDelegateToSelectYearlyTimeInterval() {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: .yearly)
        yearlyButton.isSelected = true
    }

    @objc
    private func notifyDelegateToSelectAllTimeInterval() {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: .all)
        allTimeButton.isSelected = true
    }

    private func clearButtonSelections() {
        for case let button as UIButton in stackView.arrangedSubviews {
            button.isSelected = false
        }
    }
}

protocol ChartTimeFrameSelectionViewDelegate: AnyObject {
    func chartTimeFrameSelectionView(_ view: ChartTimeFrameSelectionView, didSelect timeInterval: AlgosUSDValueInterval)
}
