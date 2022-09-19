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
//  VerifiedAssetInformationViewController.swift

import UIKit

final class VerifiedAssetInformationViewController: BaseViewController {
    private lazy var verifiedAssetInformationView = VerifiedAssetInformationView()
    private lazy var theme = Theme()
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "verified-assets-title".localized
    }

    override func prepareLayout() {
        verifiedAssetInformationView.customize(theme.verifiedAssetInformationViewTheme)
        prepareWholeScreenLayoutFor(verifiedAssetInformationView)
    }
    
    override func setListeners() {
        verifiedAssetInformationView.setListeners()
    }
    
    override func linkInteractors() {
        verifiedAssetInformationView.delegate = self
    }
}

extension VerifiedAssetInformationViewController: VerifiedAssetInformationViewDelegate {
    func verifiedAssetInformationViewDidVisitSite(_ verifiedAssetInformationView: VerifiedAssetInformationView) {
        open(AlgorandWeb.support.link)
    }
}
