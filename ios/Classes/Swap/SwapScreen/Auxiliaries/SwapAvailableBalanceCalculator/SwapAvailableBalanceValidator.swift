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

//   SwapAvailableBalanceValidator.swift

import Foundation

protocol SwapAvailableBalanceValidator {
    typealias EventHandler = (SwapAvailableBalanceValidatorEvent) -> Void
    var eventHandler: EventHandler? { get set }

    func validateAvailableSwapBalance()
}

extension SwapAvailableBalanceValidator {
    func publishEvent(
        _ event: SwapAvailableBalanceValidatorEvent
    ) {
        eventHandler?(event)
    }
}

enum SwapAvailableBalanceValidatorEvent {
    typealias AvailableBalance = UInt64

    case validated(AvailableBalance)
    case failure(SwapAssetValidationError)
}

enum SwapAssetValidationError: Error {
    typealias Balance = UInt64

    case amountInNotAvailable
    case amountOutNotAvailable
    case insufficientAlgoBalance(Balance)
    case insufficientAssetBalance(Balance)
    case unavailablePeraFee(SwapAssetDataController.Error?)
}
