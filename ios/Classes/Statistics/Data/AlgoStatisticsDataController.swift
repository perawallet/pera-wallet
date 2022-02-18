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
//   AlgoStatisticsDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AlgoStatisticsDataController: SharedDataControllerObserver {
    typealias EventHandler = (AlgoStatisticsDataControllerEvent) -> Void
    
    private typealias Error = AlgoStatisticsDataControllerError
    private typealias NetworkError = AlgoStatisticsDataControllerError.NetworkError
    
    var eventHandler: EventHandler?

    private(set) var selectedAlgoPriceTimeFrame: AlgoPriceTimeFrameSelection = .idle

    @Atomic(identifier: "algoStatisticsDataController.currency")
    private var currency: CurrencyHandle = .idle
    @Atomic(identifier: "algoStatisticsDataController.algoPriceValues")
    private var algoPriceValues: [AlgoPriceTimeFrameSelection: Result<[AlgoUSDPrice], Error>]
        = [:]
    @Atomic(identifier: "algoStatisticsDataController.algoPriceViewModels")
    private var algoPriceViewModels: [AlgoPriceTimeFrameSelection: AlgoPriceViewModel] = [:]

    private var ongoingAlgoPriceEndpoints: [EndpointOperatable] = []
    private var ongoingAlgoPriceCalculation: DispatchWorkItem?

    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    
    private let algoPriceCalculationQueue =
        DispatchQueue(label: "com.pera.queue.algoStatistics.algoPriceCalculation")
    
    init(
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
    }
    
    deinit {
        sharedDataController.remove(self)
    }
}

extension AlgoStatisticsDataController {
    func load() {
        loadCurrency()
        load(for: .lastDay)
    }
    
    func load(
        for timeFrame: AlgoPriceTimeFrameSelection
    ) {
        if selectedAlgoPriceTimeFrame == timeFrame {
            return
        }
        
        cancelLoadingAlgoPrice()
        
        let cachedViewModel = algoPriceViewModels[timeFrame]
        eventHandler?(.didUpdateAlgoPrice(cachedViewModel.unwrap { .success($0) }))

        selectedAlgoPriceTimeFrame = timeFrame

        loadAlgoPrice()
    }
    
    func reload() {
        cancelLoadingAlgoPrice()
        
        /// <note>
        /// Reset state on reloading if the last one is unavailable.
        switch algoPriceValues[selectedAlgoPriceTimeFrame] {
        case .none: eventHandler?(.didUpdateAlgoPrice(nil))
        case .success: break
        case .failure: eventHandler?(.didUpdateAlgoPrice(nil))
        }
        
        loadAlgoPrice()
    }
    
    func reset() {
        cancelLoadingAlgoPrice()
        
        $algoPriceViewModels.modify { $0 = [:] }
        eventHandler?(.didUpdateAlgoPrice(nil))
        
        loadAlgoPrice()
    }
}

extension AlgoStatisticsDataController {
    func selectPrice(
        at index: Int
    ) {
        let cachedAlgoPriceValues = algoPriceValues[selectedAlgoPriceTimeFrame]
        
        switch cachedAlgoPriceValues {
        case .none:
            break
        case .success(let algoPriceValues):
            let calculator = AlgoPriceCalculator(algoPriceValues: algoPriceValues, currency: currency)
            let selectedPriceValue = algoPriceValues[index]
            let calculationResult = calculator.calculatePrice(selectedPriceValue)
            
            switch calculationResult {
            case .success(let price):
                var viewModel = AlgoPriceViewModel()
                viewModel.bind(price)
                viewModel.bind(selectedPriceValue.timestamp)
                eventHandler?(.didSelectAlgoPrice(.success(viewModel)))
            case .failure(let error):
                eventHandler?(.didSelectAlgoPrice(.failure(.calculation(error))))
            }
        case .failure(let error):
            eventHandler?(.didSelectAlgoPrice(.failure(error)))
        }
    }
    
    func deselectPrice() {
        let cachedViewModel = algoPriceViewModels[selectedAlgoPriceTimeFrame]
        eventHandler?(.didUpdateAlgoPrice(cachedViewModel.unwrap { .success($0) }))
    }
}

extension AlgoStatisticsDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning:
            let newCurrency = sharedDataController.currency
            currencyDidLoad(newCurrency)
        default:
            break
        }
    }
}

extension AlgoStatisticsDataController {
    private func loadCurrency() {
        sharedDataController.add(self)
    }
    
    private func currencyDidLoad(
        _ newCurrency: CurrencyHandle
    ) {
        if newCurrency == currency {
            return
        }
        
        if newCurrency.isFailure &&
           currency.isAvailable {
           return
        }
        
        $currency.modify { $0 = newCurrency }
        
        /// <note>
        /// Currency updates aren't needed to be proceeded immediately.
        if hasOngoingAlgoPriceCalculation() {
            return
        }
        
        let calculation = makeAlgoPriceCalculationForSelectedAlgoPriceTimeFrame()
        proceed(with: calculation)
    }
}

extension AlgoStatisticsDataController {
    private func loadAlgoPrice() {
        let group = DispatchGroup()

        var timeFramePriceValues: [AlgoUSDPrice] = []
        var maybeRecentPriceValue: AlgoUSDPrice?
        var maybeError: NetworkError?
        
        let endpoint1 = loadAlgoPriceValues(
            for: selectedAlgoPriceTimeFrame,
            executedBy: group
        ) { result in
            switch result {
            case .success(let priceValues):
                timeFramePriceValues = priceValues
            case .failure(let error):
                if let savedError = maybeError,
                   savedError.isCancelled {
                    return
                }

                maybeError = error
            }
        }
        ongoingAlgoPriceEndpoints.append(endpoint1)
        
        let endpoint2 = loadAlgoPriceValuesForLastHour(executedBy: group) {
            result in
            switch result {
            case .success(let priceValues):
                maybeRecentPriceValue = priceValues.last
            case .failure(let error):
                if let savedError = maybeError,
                   savedError.isCancelled {
                    return
                }

                maybeError = error
            }
        }
        ongoingAlgoPriceEndpoints.append(endpoint2)
        
        group.notify(queue: .main) {
            [weak self] in
            guard let self = self else { return }
            
            self.ongoingAlgoPriceEndpoints = []
            
            if let error = maybeError {
                self.algoPriceDidFailToLoad(error)
            } else {
                self.algoPriceDidLoad((maybeRecentPriceValue, timeFramePriceValues))
            }
        }
    }
    
    private func loadAlgoPriceValuesForLastHour(
        executedBy group: DispatchGroup,
        onComplete handler: @escaping (Result<[AlgoUSDPrice], NetworkError>) -> Void
    ) -> EndpointOperatable {
        return loadAlgoPriceValues(
            for: .lastHour,
            executedBy: group,
            onComplete: handler
        )
    }
    
    private func loadAlgoPriceValues(
        for timeFrame: AlgoPriceTimeFrameSelection,
        executedBy group: DispatchGroup,
        onComplete handler: @escaping (Result<[AlgoUSDPrice], NetworkError>) -> Void
    ) -> EndpointOperatable {
        group.enter()
        return loadAlgoPriceHistory(for: timeFrame) {
            result in
            switch result {
            case .success(let priceHistory): handler(.success(priceHistory.values))
            case .failure(let error): handler(.failure(error))
            }
            
            group.leave()
        }
    }
    
    private func loadAlgoPriceHistory(
        for timeFrame: AlgoPriceTimeFrameSelection,
        onComplete handler: @escaping (Result<AlgoPriceHistory, NetworkError>) -> Void
    ) -> EndpointOperatable {
        let draft = FetchAlgoPriceHistoryDraft(timeFrame: timeFrame)
        return api.fetchAlgoPriceHistory(draft) {
            result in
            switch result {
            case .success(let history):
                handler(.success(history))
            case .failure(let apiError, let apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                handler(.failure(error))
            }
        }
    }
    
    private func cancelLoadingAlgoPrice() {
        ongoingAlgoPriceEndpoints.forEach {
            $0.cancel()
        }
        ongoingAlgoPriceEndpoints = []
        
        ongoingAlgoPriceCalculation?.cancel()
        ongoingAlgoPriceCalculation = nil
    }
    
    private func algoPriceDidLoad(
        _ algoPriceValues: AlgoPriceValues
    ) {
        let calculation = makeAlgoPriceCalculationForSelectedAlgoPriceTimeFrame(algoPriceValues)
        proceed(with: calculation)
    }
    
    private func algoPriceDidFailToLoad(
        _ error: NetworkError
    ) {
        /// <warning>
        /// Ongoing algo price endpoints are cancelled, means the selected time frame is changed,
        /// so there is no need to further calculation for the previous selected time frame.
        if error.isCancelled {
            return
        }
        
        let calculation = makeAlgoPriceCalculationForSelectedAlgoPriceTimeFrame(error)
        proceed(with: calculation)
    }
}

extension AlgoStatisticsDataController {
    private func makeAlgoPriceCalculationForSelectedAlgoPriceTimeFrame() -> DispatchWorkItem {
        /// <warning>
        /// Let's copy the selected time frame so that we can decide what to do with the calculation
        /// result later, and it won't prevent the new time frame selection to be proceeded.
        let lastSelectedAlgoPriceTimeFrame = selectedAlgoPriceTimeFrame
        return DispatchWorkItem {
            [weak self] in
            guard let self = self else { return }
            
            let result = self.calculateAlgoPrice(
                for: lastSelectedAlgoPriceTimeFrame
            )
            
            self.cache(
                result,
                for: lastSelectedAlgoPriceTimeFrame
            )
            self.publishAlgoPrice(
                result,
                for: lastSelectedAlgoPriceTimeFrame
            )
        }
    }
    
    private func makeAlgoPriceCalculationForSelectedAlgoPriceTimeFrame(
        _ algoPriceValues: AlgoPriceValues
    ) -> DispatchWorkItem {
        /// <warning>
        /// Let's copy the selected time frame so that we can decide what to do with the calculation
        /// result later, and it won't prevent the new time frame selection to be proceeded.
        let lastSelectedAlgoPriceTimeFrame = selectedAlgoPriceTimeFrame
        return DispatchWorkItem {
            [weak self] in
            guard let self = self else { return }

            let result = self.calculateAlgoPrice(
                algoPriceValues,
                for: lastSelectedAlgoPriceTimeFrame
            )
            
            self.cache(
                result,
                for: lastSelectedAlgoPriceTimeFrame
            )
            self.publishAlgoPrice(
                result,
                for: lastSelectedAlgoPriceTimeFrame
            )
        }
    }
    
    private func makeAlgoPriceCalculationForSelectedAlgoPriceTimeFrame(
        _ error: NetworkError
    ) -> DispatchWorkItem {
        /// <warning>
        /// Let's copy the selected time frame so that we can decide what to do with the calculation
        /// result later, and it won't prevent the new time frame selection to be proceeded.
        let lastSelectedAlgoPriceTimeFrame = selectedAlgoPriceTimeFrame
        return DispatchWorkItem {
            [weak self] in
            guard let self = self else { return }
            
            self.$algoPriceValues.modify {
                $0[lastSelectedAlgoPriceTimeFrame] = .failure(.network(error))
            }

            self.deleteCache(for: lastSelectedAlgoPriceTimeFrame)
            self.publishAlgoPrice(
                .failure(.network(error)),
                for: lastSelectedAlgoPriceTimeFrame
            )
        }
    }
}

extension AlgoStatisticsDataController {
    typealias AlgoPriceValues =
        (recentAlgoPriceValue: AlgoUSDPrice?, timeFrameAlgoPriceValues: [AlgoUSDPrice])
    
    private func calculateAlgoPrice(
        for timeFrame: AlgoPriceTimeFrameSelection
    ) -> Result<AlgoPriceViewModel, Error>? {
        let cachedAlgoPriceValues = algoPriceValues[timeFrame]
        
        switch cachedAlgoPriceValues {
        case .none:
            return nil
        case .success(let values):
            let calculationResult = calculateAlgoPrice(values)
            
            switch calculationResult {
            case .success(let viewModel):
                return .success(viewModel)
            case .failure(let error):
                return error.isAvailable ? .failure(error) : nil
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func calculateAlgoPrice(
        _ input: AlgoPriceValues,
        for timeFrame: AlgoPriceTimeFrameSelection
    ) -> Result<AlgoPriceViewModel, Error>? {
        let timeFrameAlgoPriceValues = input.timeFrameAlgoPriceValues
        let recentTimeFrameAlgoPriceValue = timeFrameAlgoPriceValues.last
        
        let finalAlgoPriceValues: [AlgoUSDPrice]
        if let recentAlgoPriceValue = input.recentAlgoPriceValue,
           recentAlgoPriceValue.timestamp != recentTimeFrameAlgoPriceValue?.timestamp {
            finalAlgoPriceValues = timeFrameAlgoPriceValues + [recentAlgoPriceValue]
        } else {
            finalAlgoPriceValues = timeFrameAlgoPriceValues
        }
        
        $algoPriceValues.modify {
            $0[timeFrame] = .success(finalAlgoPriceValues)
        }
        
        let calculationResult = calculateAlgoPrice(finalAlgoPriceValues)
        
        switch calculationResult {
        case .success(let viewModel):
            return .success(viewModel)
        case .failure(let error):
            return error.isAvailable ? .failure(error) : nil
        }
    }
    
    private func calculateAlgoPrice(
        _ algoPriceValues: [AlgoUSDPrice]
    ) -> Result<AlgoPriceViewModel, Error> {
        let calculator = AlgoPriceCalculator(algoPriceValues: algoPriceValues, currency: currency)
        
        var viewModel = AlgoPriceViewModel()
        
        switch calculator.calculateRecentPrice() {
        case .success(let price): viewModel.bind(price)
        case .failure(let error): return .failure(.calculation(error))
        }
        
        switch calculator.calculatePriceChangeRate() {
        case .success(let priceChangeRate):
            viewModel.bind(priceChangeRate)
            
            let chartDataSet = AlgoPriceChartDataSet(
                values: algoPriceValues,
                changeRate: priceChangeRate,
                currency: currency
            )
            viewModel.bind(chartDataSet)
        case .failure:
            viewModel.bind(0)
        }

        return .success(viewModel)
    }
}

extension AlgoStatisticsDataController {
    private func hasOngoingAlgoPriceCalculation() -> Bool {
        return ongoingAlgoPriceCalculation.unwrap(where: { !$0.isCancelled }) != nil
    }
    
    private func proceed(
        with calculation: DispatchWorkItem
    ) {
        ongoingAlgoPriceCalculation = calculation
        
        algoPriceCalculationQueue.async {
            [weak self] in
            guard let self = self else { return }

            if calculation.isCancelled {
               return
            }

            self.ongoingAlgoPriceCalculation = nil

            calculation.perform()
        }
    }
}

extension AlgoStatisticsDataController {
    private func publishAlgoPrice(
        _ result: Result<AlgoPriceViewModel, Error>?,
        for timeFrame: AlgoPriceTimeFrameSelection
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            if timeFrame != self.selectedAlgoPriceTimeFrame {
                return
            }
            
            self.eventHandler?(.didUpdateAlgoPrice(result))
        }
    }
}

extension AlgoStatisticsDataController {
    private func cache(
        _ result: Result<AlgoPriceViewModel, Error>?,
        for timeFrame: AlgoPriceTimeFrameSelection
    ) {
        switch result {
        case .none:
            deleteCache(for: timeFrame)
        case .success(let viewModel):
            cache(
                viewModel,
                for: timeFrame
            )
        case .failure:
            deleteCache(for: timeFrame)
        }
    }
    
    private func cache(
        _ viewModel: AlgoPriceViewModel,
        for timeFrame: AlgoPriceTimeFrameSelection
    ) {
        $algoPriceViewModels.modify { $0[timeFrame] = viewModel }
    }
    
    private func deleteCache(
        for timeFrame: AlgoPriceTimeFrameSelection
    ) {
        $algoPriceViewModels.modify { $0[timeFrame] = nil }
    }
}

enum AlgoStatisticsDataControllerError: Error {
    typealias NetworkError = HIPNetworkError<NoAPIModel>
    
    case network(NetworkError)
    case calculation(AlgoPriceCalculationError)
    
    var isAvailable: Bool {
        switch self {
        case .network: return true
        case .calculation(let calculationError): return calculationError.isAvailable
        }
    }
}

enum AlgoStatisticsDataControllerEvent {
    case didUpdateAlgoPrice(Result<AlgoPriceViewModel, AlgoStatisticsDataControllerError>?)
    case didSelectAlgoPrice(Result<AlgoPriceViewModel, AlgoStatisticsDataControllerError>)
}
