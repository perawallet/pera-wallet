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

        if accountValues.count == availableAccountValues.count {
            let portfolio = Portfolio(accounts: availableAccountValues)
            self = .available(portfolio)
        } else {
            self = .failure(.unavailableAccountsFound)
        }
    }
}

extension PortfolioValue {
    var isAvailable: Bool {
        let portfolio = try? unwrap()
        return portfolio != nil
    }
}

extension PortfolioValue {
    func unwrap() throws -> Portfolio {
        switch self {
        case .available(let portfolio): return portfolio
        case .failure(let error): throw error
        }
    }
}

enum PortfolioError: Error {
    case unavailableAccountsFound
}
