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

//   ExportTransactionsDraft.swift

import Foundation
import MagpieCore
import SwiftDate

struct ExportTransactionsDraft: ObjectQuery {
    var asset: Asset?
    var startDate: Date?
    var endDate: Date?

    var fileURL: URL {
        return createFileURL()
    }

    var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []

        params.append(.init(.asset, asset?.id, .setIfPresent))

        let dateFormat: DateFormat = .shortNumericReversed(separator: "-")

        let startDateValue = startDate.unwrap { $0.toFormat(dateFormat) }
        params.append(.init(.startDate, startDateValue, .setIfPresent))

        let endDateValue = endDate.unwrap { $0.toFormat(dateFormat) }
        params.append(.init(.endDate, endDateValue, .setIfPresent))

        return params
    }

    let account: Account

    init(account: Account) {
        self.account = account
    }
}

extension ExportTransactionsDraft {
    private func createFileURL() -> URL {
        var url = FileManager.default.temporaryDirectory
        url.appendPathComponent(createFilename())
        url.appendPathExtension("csv")
        return url
    }

    private func createFilename() -> String {
        let components: [String?] = [
            createFilenameRoot(),
            createFilenameAppendixForAsset(),
            createFilenameAppendixForStartDate(),
            createFilenameAppendixForEndDate()
        ]
        /// <todo>
        /// `compound(_:) is poor as performance-wise.`
        return components.compound("_")
    }

    private func createFilenameRoot() -> String {
        return account.name ?? account.address
    }

    private func createFilenameAppendixForAsset() -> String {
        switch asset {
        case .none: return "transactions"
        case .some(let asset) where asset.isAlgo: return "algos"
        case .some(let asset): return String(asset.id)
        }
    }

    private func createFilenameAppendixForStartDate() -> String? {
        return startDate.unwrap { $0.toFormat(getDateFormatForFilename()) }
    }

    private func createFilenameAppendixForEndDate() -> String? {
        guard let endDate else {
            return nil
        }

        if let startDate, startDate.isSameDay(endDate) {
            return nil
        }

        return endDate.toFormat(getDateFormatForFilename())
    }

    private func getDateFormatForFilename() -> DateFormat {
        return .shortNumeric(separator: "-")
    }
}
