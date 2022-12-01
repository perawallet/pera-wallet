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

//   SwapAvailableBalancePercentageCalculator.swift

import Foundation
import MagpieCore
import MagpieHipo

struct SwapAvailableBalancePercentageValidator: SwapAvailableBalanceValidator {
    var eventHandler: EventHandler?

    private let account: Account
    private let asset: Asset
    private let amount: UInt64
    private let api: ALGAPI

    init(
        account: Account,
        asset: Asset,
        amount: UInt64,
        api: ALGAPI
    ) {
        self.account = account
        self.asset = asset
        self.amount = amount
        self.api = api
    }

    /// <note>
    /// Returns the amount that needs to be set on the field for both success and failure cases.
    func validateAvailableSwapBalance() {
        if asset.isAlgo {
            validateAvailableBalanceForAlgo()
            return
        }

        validateAvailableBalanceForAsset()
    }
}

extension SwapAvailableBalancePercentageValidator {
    private func validateAvailableBalanceForAlgo() {
        guard let algoBalanceAfterMinBalanceAndPadding = getAlgoBalanceAfterMinBalanceAndPadding() else {
            publishEvent(.failure(.insufficientAlgoBalance(0)))
            return
        }

        if algoBalanceAfterMinBalanceAndPadding == 0 {
            publishEvent(.validated(algoBalanceAfterMinBalanceAndPadding))
            return
        }

        let draft = PeraSwapFeeDraft(
            assetID: asset.id,
            amount: amount
        )

        api.calculatePeraSwapFee(draft) {
            response in
            switch response {
            case .success(let feeResult):
                if let peraFee = feeResult.fee {
                    let algoBalanceAfterPeraFeeResult = algoBalanceAfterMinBalanceAndPadding.subtractingReportingOverflow(peraFee)

                    if algoBalanceAfterPeraFeeResult.overflow {
                        self.publishEvent(.failure(.insufficientAlgoBalance(0)))
                        return
                    }

                    let algoBalanceAfterPeraFeeValue = algoBalanceAfterPeraFeeResult.partialValue

                    if algoBalanceAfterPeraFeeValue >= amount {
                        self.publishEvent(.validated(self.amount))
                    } else {
                        self.publishEvent(.validated(algoBalanceAfterPeraFeeValue))
                    }

                    return
                }
                self.publishEvent(.failure(.unavailablePeraFee(nil)))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.publishEvent(.failure(.unavailablePeraFee(error)))
            }
        }
    }

    private func validateAvailableBalanceForAsset() {
        if amount == 0 {
            publishEvent(.failure(.insufficientAssetBalance(0)))
            return
        }

        let draft = PeraSwapFeeDraft(
            assetID: asset.id,
            amount: amount
        )

        api.calculatePeraSwapFee(draft) {
            response in

            switch response {
            case .success(let feeResult):
                if let peraFee = feeResult.fee {
                    guard let algoBalanceAfterMinBalanceAndPadding = self.getAlgoBalanceAfterMinBalanceAndPadding() else {
                        self.publishEvent(.failure(.insufficientAlgoBalance(0)))
                        return
                    }

                    let algoBalanceAfterPeraFeeResult = algoBalanceAfterMinBalanceAndPadding.subtractingReportingOverflow(peraFee)

                    if algoBalanceAfterPeraFeeResult.overflow {
                        self.publishEvent(.failure(.insufficientAlgoBalance(amount)))
                        return
                    }

                    self.publishEvent(.validated(amount))
                    return
                }

                self.publishEvent(.failure(.unavailablePeraFee(nil)))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.publishEvent(.failure(.unavailablePeraFee(error)))
            }
        }
    }
}

extension SwapAvailableBalancePercentageValidator {
    private func getAlgoBalanceAfterMinBalanceAndPadding() -> UInt64? {
        let algoBalance = account.algo.amount
        let minBalance = account.calculateMinBalance()
        let algoBalanceAfterMinBalanceResult = algoBalance.subtractingReportingOverflow(minBalance)

        if algoBalanceAfterMinBalanceResult.overflow {
            return nil
        }

        let algoBalanceAfterMinBalanceAndPaddingResult =
            algoBalanceAfterMinBalanceResult
            .partialValue
            .subtractingReportingOverflow(SwapQuote.feePadding)

        if algoBalanceAfterMinBalanceAndPaddingResult.overflow {
            return nil
        }

        return algoBalanceAfterMinBalanceAndPaddingResult.partialValue
    }
}
