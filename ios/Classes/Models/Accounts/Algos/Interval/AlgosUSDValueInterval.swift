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
//   AlgosUSDValueInterval.swift

import Foundation

enum AlgosUSDValueInterval {
    case hourly
    case daily
    case weekly
    case monthly
    case yearly
    case all

    func getIntervalRange() -> (since: TimeInterval, until: TimeInterval) {
        let currentDate = Date()

        switch self {
        case .hourly:
            return (since: TimeIntervalConstants.lastHour, until: currentDate.timeIntervalSince1970)
        case .daily:
            return (since: TimeIntervalConstants.yesterday, until: currentDate.timeIntervalSince1970)
        case .weekly:
            return (since: TimeIntervalConstants.lastWeek, until: currentDate.timeIntervalSince1970)
        case .monthly:
            return (since: TimeIntervalConstants.lastMonth, until: currentDate.timeIntervalSince1970)
        case .yearly:
            return (since: TimeIntervalConstants.lastYear, until: currentDate.timeIntervalSince1970)
        case .all:
            return (since: TimeIntervalConstants.algorandReleaseDate, until: currentDate.timeIntervalSince1970)
        }
    }

    // Time interval values that gets data from the api.
    func getIntervalRepresentation() -> String {
        switch self {
        case .hourly:
            return "5m"
        case .daily:
            return "15m"
        case .weekly:
            return "3H"
        case .monthly:
            return "12H"
        case .yearly:
            return "1W"
        case .all:
            return "2W"
        }
    }

    func toString() -> String {
        switch self {
        case .hourly:
            return "chart-time-last-hour".localized
        case .daily:
            return "chart-time-last-day".localized
        case .weekly:
            return "chart-time-last-week".localized
        case .monthly:
            return "chart-time-last-month".localized
        case .yearly:
            return "chart-time-last-year".localized
        case .all:
            return "chart-time-all".localized
        }
    }
}

private enum TimeIntervalConstants {
    static let lastHour: TimeInterval = Date().timeIntervalSince1970 - (60 * 60) // time interval of one hour ago
    static let yesterday: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24) // time interval of one day ago
    static let lastWeek: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) // time interval of one week ago
    static let lastMonth: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24 * 30) // time interval of one month ago
    static let lastYear: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24 * 30 * 12) // time interval of one year ago
    static let algorandReleaseDate: TimeInterval = 1563562146 // time interval of Algorand release date
}
