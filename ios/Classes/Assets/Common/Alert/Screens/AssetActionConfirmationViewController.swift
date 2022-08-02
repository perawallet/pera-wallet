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

    private let theme: AssetActionConfirmationViewControllerTheme
    private lazy var assetActionConfirmationView = AssetActionConfirmationView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let copyToClipboardController: CopyToClipboardController
    
    init(
        draft: AssetAlertDraft,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration,
        theme: AssetActionConfirmationViewControllerTheme
    ) {
        self.draft = draft
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme
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
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let viewModel = AssetActionConfirmationViewModel(
            draft,
            currencyFormatter: currencyFormatter
        )
        assetActionConfirmationView.bindData(viewModel)
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
                        if assetResponse.results.isEmpty {
                            self.bannerController?.presentErrorBanner(title: "asset-confirmation-not-found".localized, message: "")
                            self.closeScreen()
                            return
                        }

                        if let result = assetResponse.results[safe: 0] {
                            self.handleAssetDetailSetup(with: result)
                        }
                    case .failure:
                        self.bannerController?.presentErrorBanner(title: "asset-confirmation-not-fetched".localized, message: "")
                        self.closeScreen()
                    }
                }
            }
        }
    }
    
    private func handleAssetDetailSetup(with asset: AssetDecoration) {
        self.loadingController?.stopLoading()
        draft.asset = asset

        bindData()
    }

    private func closeScreen() {
        loadingController?.stopLoading()
        dismissScreen()
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
        closeScreen()
    }

    func assetActionConfirmationViewDidTapCopyIDButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        copyToClipboardController.copyID(draft.assetId)
    }

    func contextMenuInteractionForAssetID(
        in assetActionConfirmationView: AssetActionConfirmationView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(self.draft.assetId)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }
}

protocol AssetActionConfirmationViewControllerDelegate: AnyObject {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    )
}
