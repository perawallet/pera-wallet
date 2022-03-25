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
//  ManageAssetsViewController.swift

import UIKit
import MagpieHipo

final class ManageAssetsViewController: BaseViewController {
    weak var delegate: ManageAssetsViewControllerDelegate?

    private lazy var theme = Theme()

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var contextView = ManageAssetsView()
    
    private var account: Account
    
    private var listItems = [CompoundAsset]()
    
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    
    override func linkInteractors() {
        contextView.assetsCollectionView.delegate = self
        contextView.assetsCollectionView.dataSource = self
        contextView.setSearchInputDelegate(self)
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        contextView.customize(theme.contextViewTheme)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        loadingController?.stopLoading()
        transactionController.stopTimer()
    }
    
    override func configureAppearance() {
        contextView.updateContentStateView()
    }
}

extension ManageAssetsViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension ManageAssetsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currency = sharedDataController.currency.value
        let assetDetail = listItems[indexPath.item].detail
        let assetBase = listItems[indexPath.item].base
        
        let cell = collectionView.dequeue(AssetPreviewDeleteCell.self, at: indexPath)
        let assetPreviewModel = AssetPreviewModelAdapter.adaptAssetSelection((assetDetail, assetBase, currency))
        cell.customize(theme.assetPreviewDeleteViewTheme)
        cell.bindData(AssetPreviewViewModel(assetPreviewModel))
        cell.delegate = self
        return cell
    }
}

extension ManageAssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

extension ManageAssetsViewController {
    private func fetchAssets() {
        listItems = account.compoundAssets
        reloadAssets()
    }
    
    private func reloadAssets() {
        contextView.assetsCollectionView.reloadData()
        contextView.updateContentStateView()
    }
    
    private func filterData(with query: String) {
        listItems = account.compoundAssets.filter {
            String($0.id).contains(query) ||
            $0.detail.name.unwrap(or: "").containsCaseInsensitive(query) ||
            $0.detail.unitName.unwrap(or: "").containsCaseInsensitive(query)
        }
        reloadAssets()
    }
}

extension ManageAssetsViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text,
              !query.isEmpty else {
                  fetchAssets()
                  return
        }
        filterData(with: query)
    }
    
    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ManageAssetsViewController: AssetPreviewDeleteCellDelegate {
    func assetPreviewDeleteCellDidDelete(_ assetPreviewDeleteCell: AssetPreviewDeleteCell) {
        guard let indexPath = contextView.assetsCollectionView.indexPath(for: assetPreviewDeleteCell),
              let asset = listItems[safe: indexPath.item] else {
                  return
        }
        
        showAlertToDelete(asset)
    }
    
    private func showAlertToDelete(_ asset: CompoundAsset) {
        let assetDetail = asset.detail
        let assetAmount = account.amount(for: assetDetail)
        let assetAlertDraft: AssetAlertDraft
        
        guard let assetAmount = assetAmount else {
            return
        }
        
        assetAlertDraft = AssetAlertDraft(
            account: account,
            assetIndex: assetDetail.id,
            assetDetail: assetDetail,
            title: "asset-remove-confirmation-title".localized,
            detail: String(
                format: assetAmount.isZero
                    ? "asset-remove-confirmation-title".localized
                    : "asset-remove-transaction-warning".localized,
                "\(assetDetail.unitName ?? "title-unknown".localized)",
                "\(account.name ?? "")"
            ),
            actionTitle: "title-remove".localized,
            cancelTitle: "title-keep".localized
        )
        
        assetActionConfirmationTransition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension ManageAssetsViewController:
    AssetActionConfirmationViewControllerDelegate,
    TransactionSignChecking {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetInformation
    ) {
        if !canSignTransaction(for: &account) {
            return
        }
        
        if let assetAmount = account.amount(for: assetDetail),
           assetAmount != 0 {
            var draft = SendTransactionDraft(from: account, transactionMode: .assetDetail(assetDetail))
            draft.amount = assetAmount
            open(
                .sendTransaction(draft: draft),
                by: .push
            )
            return
        }
        
        removeAssetFromAccount(assetDetail)
    }
    
    private func removeAssetFromAccount(_ assetDetail: AssetInformation) {
        guard let creator = assetDetail.creator else {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            toAccount: Account(address: creator.address, type: .standard),
            amount: 0,
            assetIndex: assetDetail.id,
            assetCreator: creator.address
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)
        
        loadingController?.startLoadingWithMessage("title-loading".localized)

        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension ManageAssetsViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let removedAssetDetail = getRemovedAssetDetail(from: assetTransactionDraft) else {
                  return
              }

        removedAssetDetail.isRemoved = true
        delegate?.manageAssetsViewController(self, didRemove: removedAssetDetail, from: account)
        dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        loadingController?.stopLoading()
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }
    
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amount.toAlgos.toAlgosStringForLabel ?? ""
                )
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
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        loadingController?.stopLoading()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
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
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> AssetInformation? {
        return draft?.assetIndex.unwrap { account[$0]?.detail }
    }
}

protocol ManageAssetsViewControllerDelegate: AnyObject {
    func manageAssetsViewController(
        _ manageAssetsViewController: ManageAssetsViewController,
        didRemove assetDetail: AssetInformation,
        from account: Account
    )
}
