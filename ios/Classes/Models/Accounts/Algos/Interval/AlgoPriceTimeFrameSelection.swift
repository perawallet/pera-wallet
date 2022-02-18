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
//   AlgoPriceTimeFrameSelection.swift

import Foundation
import SwiftDate

struct AlgoPriceTimeFrameSelection:
    AlgoPriceChartTimeFrameSelection,
    Hashable {
    typealias Range = () -> (since: TimeInterval, until: TimeInterval)
    
    let interval: Interval
    let title: String
    let description: String
    let range: Range

    static let idle = AlgoPriceTimeFrameSelection(
        interval: .idle,
        title: "",
        description: "",
        range: { (0, 0) }
    )
    static let lastHour = AlgoPriceTimeFrameSelection(
        interval: .lastHour,
        title: "chart-time-selection-hourly".localized,
        description: "chart-time-last-hour".localized,
        range: {
            let now = Date.now()
            return ((now - 1.hours).timeIntervalSince1970, now.timeIntervalSince1970)
        }
    )
    static let lastDay = AlgoPriceTimeFrameSelection(
        interval: .lastDay,
        title: "chart-time-selection-daily".localized,
        description: "chart-time-last-day".localized,
        range: {
            let now = Date.now()
            return ((now - 1.days).timeIntervalSince1970, now.timeIntervalSince1970)
        }
    )
    static let lastWeek = AlgoPriceTimeFrameSelection(
        interval: .lastWeek,
        title: "chart-time-selection-weekly".localized,
        description: "chart-time-last-week".localized,
        range: {
            let now = Date.now()
            return ((now - 1.weeks).timeIntervalSince1970, now.timeIntervalSince1970)
        }
    )
    static let lastMonth = AlgoPriceTimeFrameSelection(
        interval: .lastMonth,
        title: "chart-time-selection-monthly".localized,
        description: "chart-time-last-month".localized,
        range: {
            let now = Date.now()
            return ((now - 1.months).timeIntervalSince1970, now.timeIntervalSince1970)
        }
    )
    static let lastYear = AlgoPriceTimeFrameSelection(
        interval: .lastYear,
        title: "chart-time-selection-yearly".localized,
        description: "chart-time-last-year".localized,
        range: {
            let now = Date.now()
            return ((now - 1.years).timeIntervalSince1970, now.timeIntervalSince1970)
        }
    )
    static let all = AlgoPriceTimeFrameSelection(
        interval: .all,
        title: "chart-time-selection-all".localized,
        description: "chart-time-all".localized,
        range: {
            let algorandReleaseDate: TimeInterval = 1563562146
            let now = Date.now()
            return (algorandReleaseDate, now.timeIntervalSince1970)
        }
    )
}

extension AlgoPriceTimeFrameSelection {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(interval)
    }
    
    static func == (
        lhs: AlgoPriceTimeFrameSelection,
        rhs: AlgoPriceTimeFrameSelection
    ) -> Bool {
        return lhs.interval == rhs.interval
    }
}

extension AlgoPriceTimeFrameSelection {
    enum Interval:
        String,
        Hashable {
        case idle
        case lastHour = "5m"
        case lastDay = "15m"
        case lastWeek = "3H"
        case lastMonth = "12H"
        case lastYear = "1W"
        case all = "2W"
    }
}
