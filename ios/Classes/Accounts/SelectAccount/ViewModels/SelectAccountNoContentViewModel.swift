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

//   SelectAccountNoContentViewModel.swift

import Foundation
import MacaroonUIKit

struct SelectAccountNoContentViewModel:
    NoContentViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var body: EditText?

    init(_ type: TransactionAction) {
        bindIcon(type)
        bindTitle(type)
        bindBody(type)
    }
}

extension SelectAccountNoContentViewModel {
    private mutating func bindIcon(_ type: TransactionAction) {
        if type == .rekeyToStandardAccount {
            self.icon = nil
        } else {
            self.icon = "img-accounts-empty"
        }
    }
    
    private mutating func bindTitle(_ type: TransactionAction) {
        let titleText: String
        
        if type == .rekeyToStandardAccount {
            titleText = "account-select-soft-rekey-empty-title"
        } else {
            titleText = "empty-accounts-title"
        }
        
        self.title = .attributedString(
            titleText
                .localized
                .bodyLargeMedium(
                    alignment: .center
                )
        )
    }
    
    private mutating func bindBody(_ type: TransactionAction) {
        let bodyText: String
        
        if type == .rekeyToStandardAccount {
            bodyText = "account-select-soft-rekey-empty-detail"
        } else {
            bodyText = "empty-accounts-detail"
        }
        
        self.body = .attributedString(
            bodyText
                .localized
                .bodyRegular(
                    alignment: .center
                )
        )
    }
}

extension SelectAccountNoContentViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title?.string)
        hasher.combine(body?.string)
    }
    
    static func == (
        lhs: SelectAccountNoContentViewModel,
        rhs: SelectAccountNoContentViewModel
    ) -> Bool {
        return
            lhs.title?.string == rhs.title?.string &&
            lhs.body?.string == rhs.body?.string
    }
}
