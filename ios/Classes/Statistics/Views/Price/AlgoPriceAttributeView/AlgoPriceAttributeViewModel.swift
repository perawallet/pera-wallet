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
//   AlgoPriceAttributeViewModel.swift

import Foundation
import MacaroonUIKit
import MagpieCore
import MagpieHipo
import SwiftDate
import UIKit

struct AlgoPriceAttributeViewModel: BindableViewModel {
    typealias Error = AlgoStatisticsDataControllerError
    
    private(set) var icon: UIImage?
    private(set) var title: EditText?
    
    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AlgoPriceAttributeViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let algoPriceChangeRate = model as? AlgoPriceChangeRate {
            bind(algoPriceChangeRate: algoPriceChangeRate)
            return
        }
        
        if let algoPriceTimestamp = model as? Double {
            bind(algoPriceTimestamp: algoPriceTimestamp)
            return
        }
        
        if let error = model as? Error {
            bind(error: error)
            return
        }
    }
}

extension AlgoPriceAttributeViewModel {
    mutating func bind(
        algoPriceChangeRate: AlgoPriceChangeRate
    ) {
        bindIcon(algoPriceChangeRate)
        bindTitle(algoPriceChangeRate)
    }
    
    mutating func bindIcon(
        _ algoPriceChangeRate: AlgoPriceChangeRate
    ) {
        switch algoPriceChangeRate {
        case .increased: icon = "icon-arrow-up-green".uiImage
        case .same: icon = nil
        case .decreased: icon = "icon-arrow-down-red".uiImage
        }
    }
    
    mutating func bindTitle(
        _ algoPriceChangeRate: AlgoPriceChangeRate
    ) {
        switch algoPriceChangeRate {
        case .increased(let value):
            bindTitle(
                value,
                Colors.Helpers.positive
            )
        case .same:
            title = nil
        case .decreased(let value):
            bindTitle(
                value,
                Colors.Helpers.negative
            )
        }
    }
}

extension AlgoPriceAttributeViewModel {
    mutating func bind(
        algoPriceTimestamp: Double
    ) {
        bindIcon(algoPriceTimestamp)
        bindTitle(algoPriceTimestamp)
    }
    
    mutating func bindIcon(
        _ algoPriceTimestamp: Double
    ) {
        icon = nil
    }
    
    mutating func bindTitle(
        _ algoPriceTimestamp: Double
    ) {
        let date = Date(timeIntervalSince1970: algoPriceTimestamp)

        title = .attributedString(
            date.toFormat("MMMM dd, yyyy - HH:mm")
                .attributed([
                    .font(Fonts.DMSans.regular.make(13)),
                    .textColor(Colors.Text.gray)
                ])
        )
    }
}

extension AlgoPriceAttributeViewModel {
    mutating func bind(
        error: Error
    ) {
        bindIcon(error)
        bindTitle(error)
    }
    
    mutating func bindIcon(
        _ error: Error
    ) {
        icon = nil
    }
    
    mutating func bindTitle(
        _ error: Error
    ) {
        title = nil
    }
}

extension AlgoPriceAttributeViewModel {
    mutating func bindTitle(
        _ value: Double,
        _ valueColor: Color
    ) {
        title = value.toPercentage.unwrap {
            .attributedString(
                $0.attributed([
                    .font(Fonts.DMMono.medium.make(13)),
                    .letterSpacing(-0.26),
                    .textColor(valueColor)
                ])
            )
        }
    }
}
