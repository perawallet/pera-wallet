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
//  AssetAdditionViewController.swift

import UIKit
import Magpie
import SVProgressHUD

class AssetAdditionViewController: BaseViewController, TestNetTitleDisplayable {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetAdditionViewControllerDelegate?
    
    private let layoutBuilder = AssetListLayoutBuilder()
    
    private lazy var assetActionConfirmationPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.modalHeight))
    )
    
    private var account: Account
    
    private var assetResults = [AssetSearchResult]()
    private var nextCursor: String?
    private var hasNext: Bool {
        return nextCursor != nil
    }

    private let paginationRequestOffset = 3
    private var assetSearchFilters = AssetSearchFilter.verified
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()

    private lazy var contentStateView = ContentStateView()
    
    private lazy var assetAdditionView = AssetAdditionView()
    
    private lazy var emptyStateView = SearchEmptyView()
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let infoBarButton = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.open(.verifiedAssetInformation, by: .present)
        }

        rightBarButtonItems = [infoBarButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets(query: nil, isPaginated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        dismissProgressIfNeeded()
        transactionController.stopTimer()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        displayTestNetTitleView(with: "title-add-asset".localized)
        emptyStateView.setTitle("asset-not-found-title".localized)
        emptyStateView.setDetail("asset-not-found-detail".localized)
    }
    
    override func setListeners() {
        assetAdditionView.delegate = self
        assetAdditionView.assetInputView.delegate = self
        assetAdditionView.assetsCollectionView.delegate = self
        assetAdditionView.assetsCollectionView.dataSource = self
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetAdditionViewLayout()
    }
}

extension AssetAdditionViewController {
    private func setupAssetAdditionViewLayout() {
        view.addSubview(assetAdditionView)
        
        assetAdditionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetAdditionViewController {
    private func fetchAssets(query: String?, isPaginated: Bool) {
        let searchDraft = AssetSearchQuery(status: assetSearchFilters, query: query, cursor: nextCursor)
        api?.searchAssets(with: searchDraft) { [weak self] response in
            switch response {
            case let .success(searchResults):
                guard let self = self else {
                    return
                }
                
                if isPaginated {
                    self.assetResults.append(contentsOf: searchResults.results)
                } else {
                    self.assetResults = searchResults.results
                }

                self.nextCursor = searchResults.parsePaginationCursor()
                
                if self.assetResults.isEmpty {
                    self.assetAdditionView.assetsCollectionView.contentState = .empty(self.emptyStateView)
                } else {
                    self.assetAdditionView.assetsCollectionView.contentState = .none
                }
                
                self.assetAdditionView.assetsCollectionView.reloadData()
            case .failure:
                guard let self = self else {
                    return
                }
                
                self.assetAdditionView.assetsCollectionView.contentState = .empty(self.emptyStateView)
                self.assetAdditionView.assetsCollectionView.reloadData()
            }
        }
    }
}

extension AssetAdditionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetResult = assetResults[indexPath.item]
        let assetDetail = AssetDetail(searchResult: assetResult)
        let cell = layoutBuilder.dequeueAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        cell.bind(AssetAdditionViewModel(assetSearchResult: assetResult))
        return cell
    }
}

extension AssetAdditionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetResult = assetResults[indexPath.item]
        
        if account.containsAsset(assetResult.id) {
            displaySimpleAlertWith(title: "asset-you-already-own-message".localized, message: "")
            return
        }
        
        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetIndex: assetResult.id,
            assetDetail: AssetDetail(searchResult: assetResult),
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized
        )
        
        let controller = open(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: assetActionConfirmationPresenter
            )
        ) as? AssetActionConfirmationViewController
        
        controller?.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let assetResult = assetResults[indexPath.item]
        let assetDetail = AssetDetail(searchResult: assetResult)
        
        if assetDetail.hasBothDisplayName() {
            return CGSize(width: UIScreen.main.bounds.width, height: layout.current.multiItemHeight)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: layout.current.itemHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == assetResults.count - paginationRequestOffset && hasNext {
            guard let query = assetAdditionView.assetInputView.inputTextField.text else {
                return
            }
            fetchAssets(query: query.isEmpty ? nil : query, isPaginated: true)
        }
    }
}

extension AssetAdditionViewController: AssetAdditionViewDelegate {
    func assetAdditionViewDidTapAllAssets(_ assetAdditionView: AssetAdditionView) {
        updateFilteringOptions(with: .all)
    }
    
    func assetAdditionViewDidTapVerifiedAssets(_ assetAdditionView: AssetAdditionView) {
        updateFilteringOptions(with: .verified)
    }
    
    private func updateFilteringOptions(with filterOption: AssetSearchFilter) {
        assetSearchFilters = filterOption
        resetPagination()
        
        let query = assetAdditionView.assetInputView.inputTextField.text
        fetchAssets(query: query, isPaginated: false)
    }
}

extension AssetAdditionViewController: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        guard let query = assetAdditionView.assetInputView.inputTextField.text else {
            assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = false
            return
        }
        
        assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = query.isEmpty
        
        resetPagination()
        fetchAssets(query: query, isPaginated: false)
    }
    
    private func resetPagination() {
        nextCursor = nil
    }
    
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = true
        assetAdditionView.assetInputView.inputTextField.text = nil
        resetPagination()
        fetchAssets(query: nil, isPaginated: false)
    }
}

extension AssetAdditionViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let session = session,
            session.canSignTransaction(for: &account) else {
            return
        }
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: assetDetail.id)
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError<TransactionError>) {
        SVProgressHUD.dismiss()
        
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
            NotificationBanner.showError(
                "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            NotificationBanner.showError("title-error".localized, message: "send-algos-receiver-address-validation".localized)
        case let .sdkError(error):
            NotificationBanner.showError("title-error".localized, message: error.debugDescription)
        default:
            break
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>) {
        SVProgressHUD.dismiss()
        switch error {
        case let .network(apiError):
            NotificationBanner.showError("title-error".localized, message: apiError.debugDescription)
        default:
            NotificationBanner.showError("title-error".localized, message: error.localizedDescription)
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
            let assetSearchResult = assetResults.first(where: { item -> Bool in
                guard let assetIndex = assetTransactionDraft.assetIndex else {
                    return false
                }
                return item.id == assetIndex
            }) else {
                return
        }
        
        delegate?.assetAdditionViewController(self, didAdd: assetSearchResult, to: account)
        popScreen()
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let itemHeight: CGFloat = 52.0
        let multiItemHeight: CGFloat = 72.0
        let modalHeight: CGFloat = 510.0
    }
}

protocol AssetAdditionViewControllerDelegate: AnyObject {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetSearchResult,
        to account: Account
    )
}
