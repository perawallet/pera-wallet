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
//   PortfolioValueViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PortfolioValueViewModel:
    ViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleColor: UIColor?
    private(set) var icon: UIImage?
    private(set) var value: EditText?

    init(
        _ type: PortfolioType,
        _ currency: Currency?
    ) {
        bindTitle(type)
        bindTitleColor(type)
        bindIcon(type)
        bindValue(type, currency)
    }
}

extension PortfolioValueViewModel {
    private mutating func bindTitle(
        _ type: PortfolioType
    ) {
        switch type {
        case .singleAccount:
            title = .string("account-detail-portfolio-title".localized)
        case .all:
            title = .string("portfolio-title".localized)
        }
    }

    private mutating func bindTitleColor(
        _ type: PortfolioType
    ) {
        switch type {
        case let .singleAccount(portfolioValue),
            let .all(portfolioValue):
            switch portfolioValue {
            case .unknown:
                titleColor = AppColors.Shared.Helpers.negative.uiColor
            case .value:
                titleColor = AppColors.Components.Text.gray.uiColor
            }
        }
    }

    private mutating func bindIcon(
        _ type: PortfolioType
    ) {
        switch type {
        case .singleAccount:
            break
        case .all:
            icon = img("icon-info-20")
        }
    }

    private mutating func bindValue(
        _ type: PortfolioType,
        _ currency: Currency?
    ) {
        switch type {
        case let .singleAccount(portfolioValue):
            switch portfolioValue {
            case .unknown:
                value = "N/A"
            case let .value(amount):
                if let currency = currency {
                    value = .string(amount.toCurrencyStringForLabel(with: currency.symbol))
                }
                value = "N/A"
            }
        case let .all(portfolioValue):
            switch portfolioValue {
            case .unknown:
                value = "N/A"
            case let .value(amount):
                if let currency = currency {
                    value = .string(amount.toCurrencyStringForLabel(with: currency.symbol))
                }
                value = "N/A"
            }
        }
    }
}

enum PortfolioType {
    case singleAccount(value: Value)
    case all(value: Value)
}

extension PortfolioType {
    enum Value {
        case unknown
        case value(Decimal)
    }
}
