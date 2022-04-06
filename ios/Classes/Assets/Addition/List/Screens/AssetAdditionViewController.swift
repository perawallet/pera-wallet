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
//  AssetAdditionViewController.swift

import UIKit
import MagpieHipo
import MagpieExceptions

final class AssetAdditionViewController: PageContainer, TestNetTitleDisplayable {
    weak var delegate: AssetAdditionViewControllerDelegate?

    private lazy var theme = Theme()

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)
    private var account: Account

    private let paginationRequestOffset = 3
    private var assetSearchFilter: AssetSearchFilter = .verified

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    private lazy var assetSearchInput = SearchInputView()
    
    private lazy var verifiedAssetsScreen = AssetListViewController(
        filter: .verified,
        configuration: configuration
    )
    
    private lazy var allAssetsScreen = AssetListViewController(
        filter: .all,
        configuration: configuration
    )

    private var currentAsset: AssetDecoration?

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "title-add-asset".localized
    }

    override func prepareLayout() {
        addAssetSearchInput()
        super.prepareLayout()
    }

    override func addPageBar() {
        view.addSubview(pageBar)
        pageBar.prepareLayout(PageBarCommonLayoutSheet())
        pageBar.snp.makeConstraints {
            $0.top.equalTo(assetSearchInput.snp.bottom).offset(theme.topPadding)
            $0.leading.trailing.equalToSuperview()
        }
    }

    override func itemDidSelect(_ index: Int) {
        let query = assetSearchInput.text

        if index == 0 {
            verifiedAssetsScreen.fetchAssets(for: query)
        } else {
            allAssetsScreen.fetchAssets(for: query)
        }
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetSearchInput.delegate = self
        transactionController.delegate = self
        verifiedAssetsScreen.delegate = self
        allAssetsScreen.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            VerifiedAssetsPageBarItem(screen: verifiedAssetsScreen),
            AllAssetsPageBarItem(screen: allAssetsScreen)
        ]
    }
}

extension AssetAdditionViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.open(.verifiedAssetInformation, by: .present)
        }

        rightBarButtonItems = [infoBarButton]
    }
}

extension AssetAdditionViewController {
    private func addAssetSearchInput() {
        assetSearchInput.customize(theme.searchInputViewTheme)
        view.addSubview(assetSearchInput)
        assetSearchInput.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension AssetAdditionViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        let index = self.selectedIndex ?? 0
        let query = view.text

        if index == 0 {
            verifiedAssetsScreen.fetchAssets(for: query)
        } else {
            allAssetsScreen.fetchAssets(for: query)
        }
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension AssetAdditionViewController:
    AssetActionConfirmationViewControllerDelegate,
    TransactionSignChecking {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        if !canSignTransaction(for: &account) {
            return
        }
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: asset.id)
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        loadingController?.startLoadingWithMessage("title-loading".localized)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }

        currentAsset = asset
    }
}

extension AssetAdditionViewController: AssetListViewControllerDelegate {
    func assetListViewController(
        _ assetListViewController: AssetListViewController,
        didSelect asset: AssetDecoration
    ) {
        if account.containsAsset(asset.id) {
            displaySimpleAlertWith(title: "asset-you-already-own-message".localized, message: "")
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetId: asset.id,
            asset: asset,
            transactionFee: Transaction.Constant.minimumFee,
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )

        assetActionConfirmationTransition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        loadingController?.stopLoading()
        currentAsset = nil
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        loadingController?.stopLoading()
        currentAsset = nil

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }
    
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

        guard let assetDetail = currentAsset else {
            return
        }

        if assetDetail.isCollectible {
            let collectibleAsset = CollectibleAsset(
                asset: ALGAsset(id: assetDetail.id),
                decoration: assetDetail
            )

            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didAddPendingCollectible,
                object: self,
                userInfo: [
                    CollectibleListLocalDataController.assetUserInfoKey: (account, collectibleAsset)
                ]
            )
        } else {
            delegate?.assetAdditionViewController(self, didAdd: assetDetail)
        }

        popScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            let bottomTransition = BottomSheetTransition(presentingViewController: self)

            bottomTransition.perform(
                .bottomWarning(
                    configurator: BottomWarningViewConfigurator(
                        image: "icon-info-green".uiImage,
                        title: "ledger-pairing-issue-error-title".localized,
                        description: .plain("ble-error-fail-ble-connection-repairing".localized),
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            break
        }
    }

    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }
}

protocol AssetAdditionViewControllerDelegate: AnyObject {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd asset: AssetDecoration
    )
}
