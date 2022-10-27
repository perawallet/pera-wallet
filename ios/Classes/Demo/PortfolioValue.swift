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

//   PortfolioValue.swift

import Foundation

enum PortfolioValue {
    case available(Portfolio)
    case partialFailure(Portfolio, PortfolioError)
    case failure(PortfolioError)

    init(
        accountValue: AccountHandle
    ) {
        self.init(accountValues: [accountValue])
    }

    init(
        accountValues: [AccountHandle]
    ) {
        let availableAccountValues = accountValues.compactMap {
            $0.isAvailable ? $0.value : nil
        }
        let portfolio = Portfolio(accounts: availableAccountValues)

        if accountValues.count == availableAccountValues.count {
            self = .available(portfolio)
        } else {
            if availableAccountValues.isEmpty {
                self = .failure(.unavailableAccountsFound)
            } else {
                self = .partialFailure(portfolio, .unavailableAccountsFound)
            }
        }
    }
}

extension PortfolioValue {
    var isAvailable: Bool {
        switch self {
        case .available: return true
        default: return false
        }
    }
}

extension PortfolioValue {
    func unwrap() throws -> Portfolio {
        switch self {
        case .available(let portfolio): return portfolio
        case .partialFailure(let portfolio, _): return portfolio
        case .failure(let error): throw error
        }
    }
}

enum PortfolioError: Error {
    case unavailableAccountsFound
}
