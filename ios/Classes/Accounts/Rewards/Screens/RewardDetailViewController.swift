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
//  RewardDetailViewController.swift

import UIKit
import SafariServices
import MacaroonBottomSheet
import MacaroonUIKit

final class RewardDetailViewController: BaseViewController {
    private lazy var rewardDetailView = RewardDetailView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let account: Account
    
    init(
        account: Account,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
        title = "rewards-title".localized
    }

    override func bindData() {
        bindData(
            RewardDetailViewModel(
                account: account,
                currencyFormatter: currencyFormatter
            )
        )
    }
    
    override func linkInteractors() {
        rewardDetailView.setListeners()
        rewardDetailView.delegate = self
    }
    
    override func prepareLayout() {
        addRewardDetailView()
    }

    func bindData(
        _ viewModel: RewardDetailViewModel
    ) {
        rewardDetailView.bindData(
            viewModel
        )
    }
}

extension RewardDetailViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

extension RewardDetailViewController {
    private func addRewardDetailView() {
        rewardDetailView.customize(RewardDetailViewTheme())
        view.addSubview(rewardDetailView)
        rewardDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension RewardDetailViewController: RewardDetailViewDelegate {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView) {
        open(AlgorandWeb.rewardsFAQ.link)
    }
}
