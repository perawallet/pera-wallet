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

//   ASAActivityScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASAActivityScreen:
    TransactionsViewController,
    ASADetailPageFragmentScreen {
    var isScrollAnchoredOnTop = true

    var scrollView: UIScrollView {
        return listView
    }

    init(
        account: Account,
        asset: Asset,
        copyToClipboardController: CopyToClipboardController?,
        configuration: ViewControllerConfiguration
    ) {
        let accountHandle = AccountHandle(account: account, status: .ready)

        let draft: TransactionListing
        if asset.isAlgo {
            /// <todo>
            /// We should have a standardized way of using `Account` or `AccountHandle`, and manage
            /// all related cases(success/failure) properly.
            draft = AlgoTransactionListing(accountHandle: accountHandle)
        } else {
            draft = AssetTransactionListing(
                accountHandle: accountHandle,
                asset: asset
            )
        }

        super.init(
            draft: draft,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )

        transactionsDataSource = TransactionsDataSource(listView, noContentType: .topAligned)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIWhenViewDidLayoutSubviews()
    }
}

/// <mark>
/// UIScrollViewDelegate
extension ASAActivityScreen {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUIWhenViewDidScroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateUIWhenViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}

extension ASAActivityScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateScrollWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenViewDidScroll() {
        updateScrollWhenViewDidScroll()
    }

    private func updateUIWhenViewWillEndDragging(
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateScrollWhenViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}
