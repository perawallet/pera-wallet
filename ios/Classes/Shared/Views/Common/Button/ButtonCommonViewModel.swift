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
//   ButtonCommonViewModel.swift

import MacaroonUIKit

struct ButtonCommonViewModel: ButtonViewModel {
    private(set) var iconSet: StateImageGroup?
    private(set) var title: EditText?

    init(title: String?, iconSet: StateImageGroup? = nil) {
        bindIconSet(iconSet)
        bindTitle(title)
    }
}

extension ButtonCommonViewModel {
    private mutating func bindTitle(_ someTitle: String?) {
        title = someTitle?.text
    }

    private  mutating func bindIconSet(_ someIconSet: StateImageGroup?) {
        iconSet = someIconSet
    }
}
