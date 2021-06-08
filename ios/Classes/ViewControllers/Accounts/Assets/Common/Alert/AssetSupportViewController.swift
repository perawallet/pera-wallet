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
//  AssetSupportViewController.swift

import UIKit
import SVProgressHUD

class AssetSupportViewController: BaseViewController {
    
    private lazy var assetSupportView = AssetSupportView()
    
    private var assetAlertDraft: AssetAlertDraft
    
    init(assetAlertDraft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.assetAlertDraft = assetAlertDraft
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssetDetailIfNeeded()
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        assetSupportView.bind(AssetSupportViewModel(draft: assetAlertDraft))
    }
    
    override func setListeners() {
        assetSupportView.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetSupportViewLayout()
    }
}

extension AssetSupportViewController {
    private func setupAssetSupportViewLayout() {
        view.addSubview(assetSupportView)
        
        assetSupportView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetSupportViewController {
    private func fetchAssetDetailIfNeeded() {
        if assetAlertDraft.assetDetail == nil {
            if let assetDetail = session?.assetDetails[assetAlertDraft.assetIndex] {
                self.handleAssetDetailSetup(with: assetDetail)
            } else {
                SVProgressHUD.show(withStatus: "title-loading".localized)
                api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(assetAlertDraft.assetIndex)")) { response in
                    switch response {
                    case let .success(assetDetailResponse):
                        self.handleAssetDetailSetup(with: assetDetailResponse.assetDetail)
                    case .failure:
                        SVProgressHUD.showError(withStatus: nil)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    private func handleAssetDetailSetup(with asset: AssetDetail) {
        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
        SVProgressHUD.dismiss()
        var assetDetail = asset
        setVerifiedIfNeeded(&assetDetail)
        assetAlertDraft.assetDetail = assetDetail
        assetSupportView.assetDisplayView.bind(AssetDisplayViewModel(assetDetail: assetDetail))
    }
    
    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail) {
        if let verifiedAssets = self.session?.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == self.assetAlertDraft.assetIndex
            }) {
            assetDetail.isVerified = true
        }
    }
}

extension AssetSupportViewController: AssetSupportViewDelegate {
    func assetSupportViewDidTapOKButton(_ assetSupportView: AssetSupportView) {
        dismissScreen()
    }
}
