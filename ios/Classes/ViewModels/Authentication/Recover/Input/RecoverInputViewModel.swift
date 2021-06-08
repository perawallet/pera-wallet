// Copyright 2019 Algorand, Inc.

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
//   RecoverInputViewModel.swift

import UIKit

class RecoverInputViewModel {
    private(set) var backgroundImage: UIImage?
    private(set) var number: String?
    private(set) var numberColor: UIColor?
    private(set) var passphraseColor: UIColor?
    private(set) var isSeparatorHidden: Bool = false

    init(state: RecoverInputView.State, index: Int) {
        setBackgroundImage(from: state)
        setNumber(from: index)
        setNumberColor(from: state)
        setPassphraseColor(from: state)
        setIsHiddenSeparator(from: state)
    }

    private func setBackgroundImage(from state: RecoverInputView.State) {
        backgroundImage = (state == .active || state == .wrong) ? img("bg-recover-input") : nil
    }

    private func setNumber(from index: Int) {
        number = "\(index + 1)"
    }

    private func setNumberColor(from state: RecoverInputView.State) {
        switch state {
        case .wrong,
             .filledWrongly:
            numberColor = Colors.General.error
        case .active,
             .empty,
             .filled:
            numberColor = Colors.Text.hint
        }
    }

    private func setPassphraseColor(from state: RecoverInputView.State) {
        switch state {
        case .wrong,
             .filledWrongly:
            passphraseColor = Colors.General.error
        case .active,
             .empty,
             .filled:
            passphraseColor = Colors.Text.primary
        }
    }

    private func setIsHiddenSeparator(from state: RecoverInputView.State) {
        isSeparatorHidden = state != .empty
    }
}
