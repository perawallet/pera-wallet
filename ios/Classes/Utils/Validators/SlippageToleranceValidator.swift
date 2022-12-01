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

//   SlippageToleranceValidator.swift

import Foundation
import MacaroonForm
import MacaroonUIKit

struct SlippageToleranceValidator: Validator {
    typealias FailMessage = (Error) -> EditText?

    private let failMessage: FailMessage?

    init(failMessage: FailMessage?) {
        self.failMessage = failMessage
    }

    func validate(
        _ inputFieldView: FormInputFieldView
    ) -> Validation {
        guard let textInputFieldView = inputFieldView as? FormTextInputFieldView else {
            return .failure(Error.required)
        }

        return validate(textInputFieldView.text)
    }

    func validate(
        _ text: String?
    ) -> Validation {
        guard let text = text,
              !text.isEmpty else {
            return .failure(Error.required)
        }

        guard let decimalAmount = text.decimalAmount else {
            return .failure(Error.required)
        }

        if decimalAmount < 0.1 || decimalAmount > 1 {
            return .failure(Error.invalid)
        }

        return .success
    }


    func getMessage(for error: ValidationError) -> EditText? {
        return failMessage?(error as! Error)
    }
}

extension SlippageToleranceValidator {
    enum Error: ValidationError {
        case required
        case invalid
    }
}
