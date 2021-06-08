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
//  RewardDetailViewController.swift

import UIKit
import SafariServices

class RewardDetailViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private let account: Account
    
    private lazy var rewardDetailView = RewardDetailView()
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        rewardDetailView.bind(RewardDetailViewModel(account: account))
    }
    
    override func linkInteractors() {
        rewardDetailView.delegate = self
    }
    
    override func prepareLayout() {
        setupRewardDetailViewLayout()
    }
}

extension RewardDetailViewController {
    private func setupRewardDetailViewLayout() {
        view.addSubview(rewardDetailView)
        
        rewardDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RewardDetailViewController: RewardDetailViewDelegate {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView) {
        guard let algorandRewardsWebsite = AlgorandWeb.rewardsFAQ.link else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: algorandRewardsWebsite)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func rewardDetailViewDidTapOKButton(_ rewardDetailView: RewardDetailView) {
        dismissScreen()
    }
}
