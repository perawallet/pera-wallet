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

final class AssetActionConfirmationViewController:
    ScrollScreen,
    BottomSheetScrollPresentable {
    weak var delegate: AssetActionConfirmationViewControllerDelegate?
    
    private(set) var draft: AssetAlertDraft

    let modalHeight: ModalHeight = .compressed

    private let theme: AssetActionConfirmationViewControllerTheme

    private lazy var loadingView = AssetActionConfirmationLoadingView()
    private lazy var contextView = AssetActionConfirmationView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let sharedDataController: SharedDataController
    private let bannerController: BannerController
    private let copyToClipboardController: CopyToClipboardController
    
    init(
        draft: AssetAlertDraft,
        copyToClipboardController: CopyToClipboardController,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        bannerController: BannerController,
        theme: AssetActionConfirmationViewControllerTheme
    ) {
        self.draft = draft
        self.copyToClipboardController = copyToClipboardController
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.theme = theme

        super.init(api: api)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackground()
        fetchAssetDetailIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLoadingIfNeeded()
    }
}

extension AssetActionConfirmationViewController {
    private func fetchAssetDetailIfNeeded() {
        if draft.hasValidAsset {
            addContext()
            return
        }

        if let cachedAsset = sharedDataController.assetDetailCollection[draft.assetId] {
            draft.asset = cachedAsset
            addContext()
            return
        }

        addLoading()

        api?.fetchAssetDetails(
            AssetFetchQuery(ids: [draft.assetId]),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case let .success(assetResponse):
                if assetResponse.results.isEmpty {
                    self.bannerController.presentErrorBanner(title: "asset-confirmation-not-found".localized, message: "")
                    self.closeScreen()
                    return
                }

                if let asset = assetResponse.results[safe: 0] {
                    self.draft.asset = asset

                    self.removeLoading()
                    self.addContext()

                    self.performLayoutUpdates(animated: self.isViewAppeared)
                }
            case .failure:
                self.bannerController.presentErrorBanner(title: "asset-confirmation-not-fetched".localized, message: "")
                self.closeScreen()
            }
        }
    }

    private func closeScreen() {
        dismissScreen()
    }
}

extension AssetActionConfirmationViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contextView.customize(theme.context)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        let viewModel = AssetActionConfirmationViewModel(
            draft,
            currencyFormatter: currencyFormatter
        )
        contextView.bindData(viewModel)

        contextView.delegate = self
    }

    private func addLoading() {
        loadingView.customize(theme.loading)

        contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        let viewModel = AssetActionConfirmationLoadingViewModel(draft: draft)
        loadingView.bindData(viewModel)

        startLoadingIfNeeded()
    }

    private func startLoadingIfNeeded() {
        if !isViewAppeared { return }

        /// <todo>
        /// Normally, it should be a data-driven, not ui-driven, checkpoint.
        if !loadingView.isDescendant(of: view) { return }

        loadingView.startAnimating()
    }

    private func removeLoading() {
        loadingView.removeFromSuperview()
        loadingView.stopAnimating()
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
