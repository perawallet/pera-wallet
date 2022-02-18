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
//   FormInputFieldAssistiveView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class FormInputFieldAssistiveView: View {
    var editError: EditText? {
        get { errorView.editText }
        set { errorView.editText = newValue }
    }
    var editHint: EditText? {
        get { hintView.editText }
        set { hintView.editText = newValue }
    }

    private lazy var errorView = Label()
    private lazy var hintView = Label()

    func customize(
        _ theme: FormInputFieldAssistiveViewTheme
    ) {
        addError(theme)
        addHint(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension FormInputFieldAssistiveView {
    private func addError(
        _ theme: FormInputFieldAssistiveViewTheme
    ) {
        errorView.customizeAppearance(theme.error)

        addSubview(errorView)
        errorView.fitToVerticalIntrinsicSize()
        errorView.contentEdgeInsets = theme.errorContentEdgeInsets
        errorView.snp.makeConstraints {
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }

    private func addHint(
        _ theme: FormInputFieldAssistiveViewTheme
    ) {
        hintView.customizeAppearance(theme.hint)

        addSubview(hintView)
        hintView.fitToVerticalIntrinsicSize()
        hintView.snp.makeConstraints {
            $0.top == errorView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}
