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
//   AlgoUSDAnalyticsViewController.swift

import UIKit

class AlgoUSDAnalyticsViewController: BaseScrollViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var algoUSDAnalyticsView = AlgoUSDAnalyticsView()

    private lazy var dataController = AlgoUSDAnalyticsDataController(api: api)

    private let account: Account
    private let currency: Currency

    private var chartEntries: [AlgosUSDValue]?
    private var selectedTimeInterval: AlgosUSDValueInterval = .hourly

    init(account: Account, currency: Currency, configuration: ViewControllerConfiguration) {
        self.account = account
        self.currency = currency
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getChartData()
    }

    override func configureAppearance() {
        super.configureAppearance()
        scrollView.alwaysBounceVertical = false
        view.backgroundColor = Colors.Background.secondary
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupAlgoUSDAnalyticsViewLayout()
    }

    override func linkInteractors() {
        super.linkInteractors()
        algoUSDAnalyticsView.delegate = self
        dataController.delegate = self
    }
}

extension AlgoUSDAnalyticsViewController {
    private func setupAlgoUSDAnalyticsViewLayout() {
        contentView.addSubview(algoUSDAnalyticsView)
        algoUSDAnalyticsView.pinToSuperview()
    }
}

extension AlgoUSDAnalyticsViewController {
    private func getChartData(for interval: AlgosUSDValueInterval = .hourly) {
        dataController.getChartData(for: interval)
    }
}

extension AlgoUSDAnalyticsViewController: AlgoUSDAnalyticsViewDelegate {
    func algoUSDAnalyticsView(_ view: AlgoUSDAnalyticsView, didSelect timeInterval: AlgosUSDValueInterval) {
        selectedTimeInterval = timeInterval
        getChartData(for: timeInterval)
    }

    func algoUSDAnalyticsView(_ view: AlgoUSDAnalyticsView, didSelectItemAt index: Int) {
        guard let values = chartEntries,
              !values.isEmpty,
              let selectedPrice = values[safe: index] else {
            return
        }

        bindHeaderView(with: values, selectedPrice: selectedPrice)
    }
    
    func algoUSDAnalyticsViewDidDeselect(_ view: AlgoUSDAnalyticsView) {
        guard let values = chartEntries,
              !values.isEmpty else {
            return
        }

        bindHeaderView(with: values, selectedPrice: nil)
    }

    private func bindHeaderView(with values: [AlgosUSDValue], selectedPrice: AlgosUSDValue?) {
        let priceChange = AlgoUSDPriceChange(
            firstPrice: values.first,
            lastPrice: values.last,
            selectedPrice: selectedPrice,
            currency: currency
        )
        algoUSDAnalyticsView.bind(
            AlgoAnalyticsHeaderViewModel(
                priceChange: priceChange,
                timeInterval: selectedTimeInterval,
                currency: currency
            )
        )
    }
}

extension AlgoUSDAnalyticsViewController: AlgoUSDAnalyticsDataControllerDelegate {
    func algoUSDAnalyticsDataController(_ dataController: AlgoUSDAnalyticsDataController, didFetch values: [AlgosUSDValue]) {
        chartEntries = values
        bindView(with: values)
    }

    func algoUSDAnalyticsDataControllerDidFailToFetch(_ dataController: AlgoUSDAnalyticsDataController) {
        chartEntries = nil
    }

    private func bindView(with values: [AlgosUSDValue]) {
        let priceChange = AlgoUSDPriceChange(firstPrice: values.first, lastPrice: values.last, selectedPrice: nil, currency: currency)
        algoUSDAnalyticsView.bind(
            AlgoUSDAnalyticsViewModel(
                account: account,
                values: values,
                priceChange: priceChange,
                timeInterval: selectedTimeInterval,
                currency: currency
            )
        )
    }
}
