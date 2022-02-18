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
//   LedgerTutorialInstructionViewModel.swift

import MacaroonUIKit

final class LedgerTutorialInstructionViewModel: BindableViewModel {
    private(set) var title: String?

    init<T>(_ model: T) {
        bind(model)
    }

    func bind<T>(_ model: T) {
        if let title = model as? String {
            bindTitle(title)
        }
    }
}

extension LedgerTutorialInstructionViewModel {
    private func bindTitle(_ someTitle: String) {
        self.title = someTitle
    }
}
