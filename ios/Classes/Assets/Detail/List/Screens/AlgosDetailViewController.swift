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
//   AlgosDetailViewController.swift

import MacaroonUIKit
import UIKit

final class AlgosDetailViewController: BaseAssetDetailViewController {
    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .assetDetail)
    }

    var route: Screen?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.track(.showAssetDetail(assetID: nil))
    }

    override func configureAppearance() {
        super.configureAppearance()
        addTitleView()
    }
}

extension AlgosDetailViewController {
    private func addTitleView() {
        let assetDetailTitleView = AssetDetailTitleView()
        assetDetailTitleView.customize(AssetDetailTitleViewTheme())
        assetDetailTitleView.bindData(AssetDetailTitleViewModel())

        navigationItem.titleView = assetDetailTitleView
    }
}
