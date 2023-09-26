// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCArbitraryDataValidator.swift

protocol WCArbitraryDataValidator {
    func validateArbitraryData(
        data: [WCArbitraryData],
        api: ALGAPI
    )
    func rejectArbitraryDataRequest(with error: WCTransactionErrorResponse)
}

extension WCArbitraryDataValidator {
    func validateArbitraryData(
        data: [WCArbitraryData],
        api: ALGAPI
    ) {
        if !hasValidNetwork(for: data, api: api) {
            rejectArbitraryDataRequest(with: .unauthorized(.nodeMismatch))
            return
        }

        if !hasValidArbitraryDataCount(for: data) {
            rejectArbitraryDataRequest(with: .invalidInput(.dataCount))
            return
        }

        if !containsSignerInTheWallet(for: data) {
            rejectArbitraryDataRequest(with: .unauthorized(.dataSignerNotFound))
            return
        }
    }

    private func hasValidNetwork(
        for data: [WCArbitraryData],
        api: ALGAPI
    ) -> Bool {
        let allowedChainIDs = api.network.allowedChainIDs
        return data.contains {
            return $0.chainID.unwrap(allowedChainIDs.contains) ?? false
        }
    }

    private func hasValidArbitraryDataCount(for data: [WCArbitraryData]) -> Bool {
        return data.count <= supportedArbitraryDataCount
    }

    private func containsSignerInTheWallet(for data: [WCArbitraryData]) -> Bool {
        for datum in data {
            if !datum.requestedSigner.containsSignerInTheWallet {
                return false
            }
        }

        return true
    }
}

extension WCArbitraryDataValidator {
    private var supportedArbitraryDataCount: Int {
        return 1000
    }
}
