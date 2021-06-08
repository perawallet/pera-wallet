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
//  VerifiedAssetInformationViewController.swift

import UIKit

class VerifiedAssetInformationViewController: BaseViewController {
    
    private lazy var verifiedAssetInformationView = VerifiedAssetInformationView()
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        navigationItem.title = "verified-assets-title".localized
    }
    
    override func linkInteractors() {
        verifiedAssetInformationView.delegate = self
    }
    
    override func prepareLayout() {
        setupVerifiedAssetInformationViewLayout()
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension VerifiedAssetInformationViewController {
    private func setupVerifiedAssetInformationViewLayout() {
        view.addSubview(verifiedAssetInformationView)
        
        verifiedAssetInformationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension VerifiedAssetInformationViewController: VerifiedAssetInformationViewDelegate {
    func verifiedAssetInformationViewDidVisitSite(_ verifiedAssetInformationView: VerifiedAssetInformationView) {
        if let url = AlgorandWeb.support.link {
            open(url)
        }
    }
}
