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

//   SwapSlippageTolerancePercentageValidator.swift

import Foundation
import MacaroonForm
import MacaroonUIKit

struct SwapSlippageTolerancePercentageValidator: MacaroonForm.Validator {
    private typealias Error = SwapSlippageTolerancePercentageValidationError

    private let messageResolver: SwapSlippageTolerancePercentageValidationMessageResolver?

    init(messageResolver: SwapSlippageTolerancePercentageValidationMessageResolver? = SwapSlippageTolerancePercentageValidationMessageGenericResolver()) {
        self.messageResolver = messageResolver
    }

    func validate(_ inputFieldView: MacaroonForm.FormInputFieldView) -> MacaroonForm.Validation {
        let textInputFieldView = inputFieldView as? MacaroonForm.FormTextInputFieldView
        let text = textInputFieldView?.text
        return validate(text)
    }

    func validate(_ text: String?) -> MacaroonForm.Validation {
        guard let text = text.unwrapNonEmptyString() else {
            return .success
        }

        guard let percentage = Decimal(string: text, locale: Locale.current) else {
            return .failure(Error.corrupted)
        }

        if percentage < Error.minLimit {
            return .failure(Error.minLimitExceeded)
        }

        if percentage > Error.maxLimit {
            return .failure(Error.maxLimitExceeded)
        }

        return .success
    }

    func getMessage(for error: MacaroonForm.ValidationError) -> MacaroonUIKit.EditText? {
        let message = messageResolver?[error as! SwapSlippageTolerancePercentageValidationError]
        return .string(message)
    }
}

protocol SwapSlippageTolerancePercentageValidationMessageResolver {
    typealias Error = SwapSlippageTolerancePercentageValidationError

    subscript (error: Error) -> String? { get }
}

struct SwapSlippageTolerancePercentageValidationMessageGenericResolver: SwapSlippageTolerancePercentageValidationMessageResolver {
    private var errorMessages: [Self.Error : String] = {
        var map: [Self.Error : String] = [:]
        Self.Error.allCases.forEach { error in
            switch error {
            default:
                map[error] = "swap-slippage-percentage-validation-error-limitExceeded".localized(
                    params:
                    (Self.Error.minLimit / 100).toPercentageWith(fractions: 2).someString,
                    (Self.Error.maxLimit / 100).toPercentageWith(fractions: 2).someString
                )
            }
        }
        return map
    }()

    subscript(error: Self.Error) -> String? {
        get { errorMessages[error] }
        set { errorMessages[error] = newValue }
    }
}

enum SwapSlippageTolerancePercentageValidationError:
    CaseIterable,
    ValidationError {
    case corrupted
    case minLimitExceeded
    case maxLimitExceeded

    fileprivate static let minLimit: Decimal = 0.01
    fileprivate static let maxLimit: Decimal = 10
}
