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
//   QRScannerOverlayViewModel.swift

import MacaroonUIKit

final class QRScannerOverlayViewModel: ViewModel {
    private(set) var connectedAppsButtonTitle: String?

    init(dAppCount: UInt) {
        bindTitle(dAppCount)
    }
}

extension QRScannerOverlayViewModel {
    private func bindTitle(_ dAppCount: UInt) {
        guard dAppCount != 0 else { return }

        let title: String

        if dAppCount > 1 {
            title = "qr-scan-connected-app-count".localized(params: "\(dAppCount)")
        } else {
            title = "qr-scan-connected-app-singular-count".localized(params: "1")
        }

        self.connectedAppsButtonTitle = title
    }
}
