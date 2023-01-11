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
//   QRAddressLabelViewModel.swift

import Foundation
import MacaroonUIKit

final class QRAddressLabelViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var address: TextProvider?
    
    init(title: String, address: String) {
        bindTitle(title)
        bindAddress(address)
    }
}

extension QRAddressLabelViewModel {
    private func bindTitle(_ title: String) {
        self.title = title.bodyLargeMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingMiddle
        )
    }

    private func bindAddress(_ address: String) {
        self.address = address.bodyRegular(
            alignment: .center,
            lineBreakMode: .byTruncatingMiddle
        )
    }
}
