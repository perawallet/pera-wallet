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
    
    private lazy var rewardCalculator: RewardCalculator = {
        guard let api = api else {
            fatalError("Api must be set before accessing reward calculator.")
        }

        return RewardCalculator(api: api, account: account, sharedDataController: sharedDataController)
    }()

    private let account: Account
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func configureAppearance() {
        title = "rewards-title".localized
    }

    override func bindData() {
        rewardDetailView.bindData(RewardDetailViewModel(account))
    }
    
    override func linkInteractors() {
        rewardDetailView.setListeners()
        rewardDetailView.delegate = self
        rewardCalculator.delegate = self
    }
    
    override func prepareLayout() {
        addRewardDetailView()
    }
}

extension RewardDetailViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
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

extension RewardDetailViewController: RewardCalculatorDelegate {
    func rewardCalculator(_ rewardCalculator: RewardCalculator, didCalculate rewards: Decimal) {
        rewardDetailView.bindData(RewardDetailViewModel(account: account, calculatedRewards: rewards))
    }
}

extension RewardDetailViewController: RewardDetailViewDelegate {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView) {
        open(AlgorandWeb.rewardsFAQ.link)
    }
}
