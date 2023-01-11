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
//  SwiftDate+Region.swift

import SwiftDate
import Foundation

extension SwiftDate {
    static func setupDateRegion() {
        SwiftDate.defaultRegion = Region(
            calendar: Calendar.autoupdatingCurrent,
            zone: TimeZone.autoupdatingCurrent,
            locale: Locales.autoUpdating
        )
    }
}

enum DateFormat {
    case fullNumeric
    case fullNumericWithoutTimezone
    case shortNumeric(separator: String = "/")
    case shortNumericReversed(separator: String = "-")
    case dateAndTime
    case time
    case creditCardExpire
}

extension DateFormat {
    var raw: String {
        switch self {
        case .fullNumeric: return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case .fullNumericWithoutTimezone: return "yyyy-MM-dd HH:mm:ss"
        case .shortNumeric(let separator): return "MM\(separator)dd\(separator)yyyy"
        case .shortNumericReversed(let separator): return "yyyy\(separator)MM\(separator)dd"
        case .dateAndTime: return "dd/MM/yyyy, hh:mm:ss a"
        case .time: return "h:mm a"
        case .creditCardExpire: return "MM/yyyy"
        }
    }
}

extension Date {
    func toFormat(_ format: DateFormat) -> String {
        return toFormat(format.raw)
    }

    static func toFormatter(_ format: DateFormat) -> DateFormatter {
        return Date().formatter(format: format.raw)
    }
}

extension String {
    func toDate(_ format: DateFormat) -> Date? {
        return toDate(format.raw)?.date
    }
}
