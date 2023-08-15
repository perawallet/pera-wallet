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
//  URL+Link.swift

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }

    func extractMoonPayParams() -> MoonPayParams? {
        guard let address = host else {
            return nil
        }

        guard
            let transactionStatusRaw = queryParameters?[MoonPayParams.Keys.transactionStatus.rawValue],
            let transactionStatus = MoonPayParams.TransactionStatus(rawValue: transactionStatusRaw),
            let transactionId = queryParameters?[MoonPayParams.Keys.transactionId.rawValue]
        else {
            return nil
        }

        let amount = queryParameters?[MoonPayParams.Keys.amount.rawValue]

        return MoonPayParams(
            address: address,
            amount: amount,
            transactionStatus: transactionStatus,
            transactionId: transactionId
        )
    }

    func appendingQueryParameters(_ params: [String: String]) -> URL? {
        var components = URLComponents(string: absoluteString)
        var queryItems = components?.queryItems ?? []
        queryItems += params.map(URLQueryItem.init)
        components?.queryItems = queryItems
        return components?.url
    }
}
