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
//  ContactDetailViewController.swift

import UIKit

final class ContactDetailViewController: BaseScrollViewController {
    weak var delegate: ContactDetailViewControllerDelegate?

    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .contactDetail)
    }

    private lazy var accountListModalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var theme = Theme()
    private lazy var contactDetailView = ContactDetailView()

    private lazy var currencyFormatter = CurrencyFormatter()
    
    private let contact: Contact
    private var contactAccount: Account?
    private var selectedAsset: StandardAsset?
    private var assetPreviews: [AssetPreviewModel] = []

    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContactAccount()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contactDetailView.contactInformationView.bindData(ContactInformationViewModel(contact))
    }
    
    override func linkInteractors() {
        contactDetailView.assetsCollectionView.delegate = self
        contactDetailView.assetsCollectionView.dataSource = self
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactDeleted(notification:)),
            name: .ContactDeletion,
            object: nil
        )
        contactDetailView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        contentView.addSubview(contactDetailView)
        contactDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ContactDetailViewController {
    private func addBarButtons() {
        let editBarButtonItem = ALGBarButtonItem(kind: .edit) { [unowned self] in
            let controller = self.open(
                .editContact(contact: self.contact),
                by: .push
            ) as? EditContactViewController
            controller?.delegate = self
        }
        let shareBarButtonItem = ALGBarButtonItem(kind: .share) { [unowned self] in
            self.shareContact()
        }
        rightBarButtonItems = [editBarButtonItem, shareBarButtonItem]
    }
}

extension ContactDetailViewController {
    private func fetchContactAccount() {
        guard let address = contact.address else {
            return
        }
        
        loadingController?.startLoadingWithMessage("title-loading".localized)

        api?.fetchAccount(
            AccountFetchDraft(publicKey: address),
            queue: .main,
            ignoreResponseOnCancelled: true
        ) { [weak self] response in
            guard let self = self else { return }

            let currency = self.sharedDataController.currency
            let currencyFormatter = self.currencyFormatter

            switch response {
            case let .success(accountWrapper):
                if !accountWrapper.account.isSameAccount(with: address) {
                    self.loadingController?.stopLoading()
                    return
                }

                let account = accountWrapper.account
                self.contactAccount = account
                
                let algoAssetItem = AssetItem(
                    asset: account.algo,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let preview = AssetPreviewModelAdapter.adapt(algoAssetItem)
                self.assetPreviews.append(preview)
                
                if account.hasAnyAssets() {
                    if let assets = account.assets {
                        var assetsToBeFetched: [AssetID] = []

                        for asset in assets {
                            if self.sharedDataController.assetDetailCollection[asset.id] == nil {
                                assetsToBeFetched.append(asset.id)
                            }
                        }

                        self.api?.fetchAssetDetails(
                            AssetFetchQuery(ids: assetsToBeFetched),
                            queue: .main,
                            ignoreResponseOnCancelled: false
                        ) { [weak self] assetResponse in
                            guard let self = self else {
                                return
                            }

                            switch assetResponse {
                            case let .success(assetDetailResponse):
                                assetDetailResponse.results.forEach {
                                    self.sharedDataController.assetDetailCollection[$0.id] = $0
                                }

                                for asset in assets {
                                    if let assetDetail = self.sharedDataController.assetDetailCollection[asset.id] {
                                        if assetDetail.isCollectible {
                                            let collectible = CollectibleAsset(asset: asset, decoration: assetDetail)
                                            account.append(collectible)
                                        } else {
                                            let standardAsset = StandardAsset(asset: asset, decoration: assetDetail)
                                            account.append(standardAsset)

                                            let standardAssetItem = AssetItem(
                                                asset: standardAsset,
                                                currency: currency,
                                                currencyFormatter: currencyFormatter
                                            )
                                            let preview = AssetPreviewModelAdapter.adapt(standardAssetItem)
                                            self.assetPreviews.append(preview)
                                        }
                                    }
                                }

                                self.loadingController?.stopLoading()
                                self.contactAccount = account
                                self.contactDetailView.assetsCollectionView.reloadData()
                            case .failure:
                                self.loadingController?.stopLoading()
                            }
                        }
                    } else {
                        self.loadingController?.stopLoading()
                        self.contactDetailView.assetsCollectionView.reloadData()
                    }
                } else {
                    self.loadingController?.stopLoading()
                    self.contactDetailView.assetsCollectionView.reloadData()
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    self.contactAccount = Account(address: address)
                    self.loadingController?.stopLoading()

                    guard let account = self.contactAccount else { return }

                    let algoAssetItem = AlgoAssetItem(
                        account: account,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                    let algoAssetPreview = AssetPreviewModelAdapter.adapt(algoAssetItem)
                    self.assetPreviews.append(algoAssetPreview)

                    self.contactDetailView.assetsCollectionView.reloadData()
                } else {
                    self.contactAccount = nil
                    self.loadingController?.stopLoading()
                }
            }
        }
    }
    
    @objc
    private func didContactDeleted(notification: Notification) {
        closeScreen(by: .pop, animated: false)
    }
}

extension ContactDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetPreviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AssetPreviewActionCell.self, at: indexPath)
        cell.customize(theme.assetPreviewActionViewTheme)
        cell.bindData(AssetPreviewViewModel(assetPreviews[indexPath.item]))
        cell.delegate = self
        return cell
    }
}

extension ContactDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        openASADiscoveryScreen(at: indexPath)
    }

    private func openASADiscoveryScreen(
        at indexPath: IndexPath
    ) {
        /// <note> Do not open the Discovery screen for Algo
        if indexPath.item == 0 {
            return
        }

        guard let asset = assetPreviews[safe: indexPath.item]?.asset else {
            return
        }

        let assetDecoration = AssetDecoration(asset: asset)

        let screen = Screen.asaDiscovery(
            account: nil,
            quickAction: nil,
            asset: assetDecoration
        )
        open(
            screen,
            by: .present
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

extension ContactDetailViewController: AssetPreviewActionCellDelegate {
    func assetPreviewSendCellDidTapSendButton(_ assetPreviewSendCell: AssetPreviewActionCell) {
        guard let itemIndex = contactDetailView.assetsCollectionView.indexPath(for: assetPreviewSendCell),
            let contactAccount = contactAccount else {
            return
        }

        let mode: AccountListViewController.Mode = .contact(asset: itemIndex.item == 0 ? nil : contactAccount.standardAssets?[itemIndex.item - 1])
        let accountListDataSource = AccountListDataSource(
            sharedDataController: sharedDataController,
            mode: mode,
            currencyFormatter: currencyFormatter
        )

        guard !accountListDataSource.accounts.isEmpty else {
            bannerController?.presentErrorBanner(
                title: "asset-support-your-add-title".localized,
                message: "asset-support-your-add-message".localized
            )
            return
        }

        accountListModalTransition.perform(
            .accountList(
                mode: mode,
                delegate: self
            ),
            by: .present
        )

        if itemIndex.item != 0 {
            selectedAsset = contactAccount.standardAssets?[itemIndex.item - 1]
        }
    }
}

extension ContactDetailViewController {
    private func shareContact() {
        guard let address = contact.address else {
            return
        }
        
        let sharedItem = [address]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}

extension ContactDetailViewController: ContactDetailViewDelegate {
    func contactDetailViewDidTapQRButton(_ view: ContactDetailView) {
        guard let address = contact.address else {
            return
        }

        let draft = QRCreationDraft(address: address, mode: .address, title: contact.name)
        open(.qrGenerator(title: contact.name, draft: draft, isTrackable: true), by: .present)
    }
}

extension ContactDetailViewController: AddContactViewControllerDelegate {
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact) {
        contactDetailView.contactInformationView.bindData(ContactInformationViewModel(contact))
        delegate?.contactDetailViewController(self, didUpdate: contact)
    }
}

extension ContactDetailViewController: EditContactViewControllerDelegate {
    func editContactViewController(_ editContactViewController: EditContactViewController, didSave contact: Contact) {
        contactDetailView.contactInformationView.bindData(ContactInformationViewModel(contact))
        delegate?.contactDetailViewController(self, didUpdate: contact)
    }
}

extension ContactDetailViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: AccountHandle) {
        viewController.dismissScreen()

        var transactionDraft: SendTransactionDraft
        
        if let asset = selectedAsset {
            transactionDraft = SendTransactionDraft(
                from: account.value,
                transactionMode: .asset(asset)
            )
        } else {
            transactionDraft = SendTransactionDraft(
                from: account.value,
                transactionMode: .algo
            )
        }

        transactionDraft.toContact = contact

        open(.sendTransaction(draft: transactionDraft), by: .present)
    }

    func accountListViewControllerDidCancelScreen(_ viewController: AccountListViewController) {
        viewController.dismissScreen()
    }
}

protocol ContactDetailViewControllerDelegate: AnyObject {
    func contactDetailViewController(_ contactDetailViewController: ContactDetailViewController, didUpdate contact: Contact)
}
