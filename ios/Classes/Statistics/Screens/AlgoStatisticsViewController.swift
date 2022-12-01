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
//   AlgoStatisticsViewController.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

final class AlgoStatisticsViewController:
    BaseScrollViewController,
    NotificationObserver,
    ShimmerAnimationDisplaying {
    var notificationObservations: [NSObjectProtocol] = []
    
    override var prefersLargeTitle: Bool {
        return true
    }

    private lazy var algoPriceView = AlgoPriceView()
    private lazy var algoPriceTimeFrameSelectionView = AlgoPriceChartTimeFrameSelectionView()
    
    private var algoPriceTimeFrameOptions: [AlgoPriceTimeFrameSelection] = []

    private var chartEntries: [AlgoUSDPrice]?
    private var selectedTimeInterval: AlgoPriceTimeFrameSelection = .lastYear
        
    private let dataController: AlgoStatisticsDataController
    
    init(
        dataController: AlgoStatisticsDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        navigationItem.title = "title-algorand".localized
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func setListeners() {
        super.setListeners()
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didUpdateAlgoPrice(let result):
                switch result {
                case .none:
                    self.algoPriceView.bindData(nil)
                    
                    if !self.algoPriceTimeFrameOptions.isEmpty {
                        return
                    }

                    self.algoPriceTimeFrameSelectionView.bindData(nil)

                    self.algoPriceTimeFrameOptions = []
                case .success(let viewModel):
                    self.algoPriceView.bindData(viewModel)
                    
                    if !self.algoPriceTimeFrameOptions.isEmpty {
                        return
                    }
                    
                    let options: [AlgoPriceTimeFrameSelection] = [
                        .lastDay,
                        .lastWeek,
                        .lastMonth,
                        .lastYear,
                        .all
                    ]
                    let algoPriceTimeFrameSelectionViewModel =
                        AlgoPriceChartTimeFrameSelectionViewModel(options)
                    self.algoPriceTimeFrameSelectionView.bindData(
                        algoPriceTimeFrameSelectionViewModel
                    )
                    self.algoPriceTimeFrameSelectionView.selectedIndex =
                        options.firstIndex(of: self.dataController.selectedAlgoPriceTimeFrame)
                    
                    self.algoPriceTimeFrameOptions = options
                case .failure(let error):
                    var algoPriceViewModel = AlgoPriceViewModel()
                    algoPriceViewModel.bind(error: error)
                    self.algoPriceView.bindData(algoPriceViewModel)
                    
                    let algoPriceTimeFrameSelectionViewModel =
                        AlgoPriceChartTimeFrameSelectionViewModel(error)
                    self.algoPriceTimeFrameSelectionView.bindData(
                        algoPriceTimeFrameSelectionViewModel
                    )
                    
                    self.algoPriceTimeFrameOptions = []
                }
            case .didSelectAlgoPrice(let result):
                switch result {
                case .success(let viewModel):
                    self.algoPriceView.bindPriceData(viewModel)
                case .failure(let error):
                    var algoPriceViewModel = AlgoPriceViewModel()
                    algoPriceViewModel.bind(error: error)
                    self.algoPriceView.bindPriceData(algoPriceViewModel)
                }
            }
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        algoPriceView.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .selectChartAtPrice(let index): self.dataController.selectPrice(at: index)
            case .deselectChart: self.dataController.deselectPrice()
            }
        }
        algoPriceTimeFrameSelectionView.selectionHandler = {
            [weak self] index in
            guard let self = self else { return }
            
            guard let timeFrameSelection = self.algoPriceTimeFrameOptions[safe: index] else {
                return
            }
            
            self.dataController.load(for: timeFrameSelection)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
        startAnimating()
        loadData()
    }

    override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(animated)
        
        if !isViewFirstAppeared {
            restartAnimating()
            reloadData()
        }        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimating()
    }
}

extension AlgoStatisticsViewController {
    private func build() {
        addAlgoPrice()
        addAlgoPriceTimeFrameSelection()
    }
    
    private func addAlgoPrice() {
        algoPriceView.customize(AlgoPriceViewTheme())
        
        contentView.addSubview(algoPriceView)
        algoPriceView.snp.makeConstraints {
            $0.top == 18
            $0.leading == 0
            $0.bottom <= 0
            $0.trailing == 0
        }
        
        algoPriceView.bindData(nil)
    }
    
    private func addAlgoPriceTimeFrameSelection() {
        algoPriceTimeFrameSelectionView.customize(AlgoPriceChartTimeFrameSelectionViewTheme())
        
        contentView.addSubview(algoPriceTimeFrameSelectionView)
        algoPriceTimeFrameSelectionView.snp.makeConstraints {
            $0.top == algoPriceView.snp.bottom + 40
            $0.leading == 24
            $0.bottom <= 0
            $0.trailing == 24
            
            $0.fitToHeight(30)
        }
        
        algoPriceTimeFrameSelectionView.bindData(nil)
    }
}

extension AlgoStatisticsViewController {
    private func loadData() {
        dataController.load()
    }
    
    private func reloadData() {
        dataController.reload()
    }
}
