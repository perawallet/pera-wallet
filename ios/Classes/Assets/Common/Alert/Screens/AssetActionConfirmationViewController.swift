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
//  AssetActionConfirmationViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class AssetActionConfirmationViewController: BaseViewController {
    weak var delegate: AssetActionConfirmationViewControllerDelegate?
    
    private(set) var draft: AssetAlertDraft

    private lazy var theme = Theme()
    private lazy var assetActionConfirmationView = AssetActionConfirmationView()
    
    init(draft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAssetDetailIfNeeded()
    }
    
    override func setListeners() {
        assetActionConfirmationView.setListeners()
        assetActionConfirmationView.delegate = self
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func prepareLayout() {
        assetActionConfirmationView.customize(theme.assetActionConfirmationViewTheme)
        view.addSubview(assetActionConfirmationView)
        assetActionConfirmationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        assetActionConfirmationView.bindData(AssetActionConfirmationViewModel(draft))
    }
}

extension AssetActionConfirmationViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

extension AssetActionConfirmationViewController {
    private func fetchAssetDetailIfNeeded() {
        if !draft.hasValidAsset {
            if let asset = sharedDataController.assetDetailCollection[draft.assetId] {
                handleAssetDetailSetup(with: asset)
            } else {
                loadingController?.startLoadingWithMessage("title-loading".localized)

                api?.fetchAssetDetails(
                    AssetFetchQuery(ids: [draft.assetId]),
                    queue: .main,
                    ignoreResponseOnCancelled: false
                ) { [weak self] response in
                    guard let self = self else {
                        return
                    }

                    switch response {
                    case let .success(assetResponse):
                        if let result = assetResponse.results[safe: 0] {
                            self.handleAssetDetailSetup(with: result)
                        }
                    case .failure:
                        self.loadingController?.stopLoading()
                    }
                }
            }
        }
    }
    
    private func handleAssetDetailSetup(with asset: AssetDecoration) {
        self.loadingController?.stopLoading()
        draft.asset = asset
        assetActionConfirmationView.bindData(AssetActionConfirmationViewModel(draft))
    }
}

extension AssetActionConfirmationViewController: AssetActionConfirmationViewDelegate {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        closeScreen(by: .dismiss, animated: true) { [weak self] in
            guard let self = self else {
                return
            }

            if let asset = self.draft.asset {
                self.delegate?.assetActionConfirmationViewController(self, didConfirmAction: asset)
            }
        }
    }
    
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        dismissScreen()
    }

    func assetActionConfirmationViewDidTapCopyIDButton(_ assetActionConfirmationView: AssetActionConfirmationView, assetID: String?) {
        UIPasteboard.general.string = assetID
        bannerController?.presentInfoBanner("asset-id-copied-title".localized)
    }
}

protocol AssetActionConfirmationViewControllerDelegate: AnyObject {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    )
}
