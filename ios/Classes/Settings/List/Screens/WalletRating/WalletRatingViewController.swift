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
//   WalletRatingViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class WalletRatingViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var walletRatingView = WalletRatingView()
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func prepareLayout() {
        view.addSubview(walletRatingView)
        walletRatingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setListeners() {
        walletRatingView.setListeners()
        walletRatingView.delegate = self
    }
}

extension WalletRatingViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

extension WalletRatingViewController: WalletRatingViewDelegate {
    func walletRatingViewDidTapButton(_ walletRatingView: WalletRatingView) {
        AlgorandAppStoreReviewer().requestManualReview(forAppWith: Environment.current.appID)
    }
}
