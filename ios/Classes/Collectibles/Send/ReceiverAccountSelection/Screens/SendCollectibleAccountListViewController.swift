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

//   SendCollectibleAccountListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

/// <todo>
/// `AccountSelectScreen` should use this screen, rename & refactor if needed.
final class SendCollectibleAccountListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var searchInputView = SearchInputView()
    private lazy var clipboardCanvasView = UIView()
    private lazy var clipboardView = AccountClipboardView()

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = SendCollectibleAccountListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = SendCollectibleAccountListLayout(
        listDataSource: listDataSource
    )

    private lazy var listDataSource = SendCollectibleAccountListDataSource(listView)

    private let dataController: SendCollectibleAccountListDataController
    private let theme: SendCollectibleAccountListViewControllerTheme

    /// <todo> Get selected address and change background of previously selected cell.
    init(
        dataController: SendCollectibleAccountListDataController,
        theme: SendCollectibleAccountListViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme

        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    override func configureNavigationBarAppearance() {
        navigationItem.title = "collectible-send-account-list-title".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func linkInteractors() {
        super.linkInteractors()

        listView.delegate = self
        searchInputView.delegate = self

        linkPasteboardInteractors()
    }

    private func build() {
        addSearchInputView()
        addBackground()
        addListView()
        addClipboardView()

        displayClipboardIfNeeded()
    }
}

extension SendCollectibleAccountListViewController {
    private func linkPasteboardInteractors() {
        clipboardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapCopyAddress))
        )

        observe(notification: UIPasteboard.changedNotification) {
            [weak self] _ in
            guard let self = self else { return }

            self.displayClipboardIfNeeded()
        }

        observeWhenApplicationWillEnterForeground {
            [weak self] _ in
            guard let self = self else { return }

            self.displayClipboardIfNeeded()
        }
    }

    @objc
    private func didTapCopyAddress() {
        if let address = UIPasteboard.general.validAddress {
            searchInputView.setText(address)
        }
    }
}

extension SendCollectibleAccountListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addSearchInputView() {
        searchInputView.customize(
            QRSearchInputViewTheme(
                placeholder: "account-select-header-search-title".localized,
                family: .current
            )
        )

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == theme.searchInputViewTopPadding
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }
    }

    private func addClipboardView() {
        view.addSubview(clipboardCanvasView)
        clipboardCanvasView.customizeAppearance(theme.background)

        clipboardCanvasView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }

        clipboardView.customize(AccountClipboardViewTheme())

        clipboardCanvasView.addSubview(clipboardView)

        clipboardView.snp.makeConstraints {
            $0.setPaddings(theme.clipboardPaddings)
        }
    }
    
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}

extension SendCollectibleAccountListViewController {
    @objc private func displayClipboardIfNeeded() {
        let address = UIPasteboard.general.validAddress
        let isVisible = address != nil

        clipboardCanvasView.isHidden = !isVisible

        if isVisible {
            clipboardView.bindData(
                AccountClipboardViewModel(address!)
            )
        }

        UIView.animate(withDuration: 0.3) {
            self.listView.contentInset.top = isVisible ? self.theme.contentInsetTopForClipboard : 0
        }
    }
}

extension SendCollectibleAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension SendCollectibleAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.startAnimating()
            default:
                break
            }
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
}

extension SendCollectibleAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let item, _):
            guard let address = item.address,
                  let account = dataController[accountAddress: address] else {
                return
            }

            eventHandler?(.didSelectAccount(account))
        case .contact(let item, _):
            guard let address = item.fullAddress,
                  let contact = dataController[contactAddress: address] else {
                return
            }

            eventHandler?(.didSelectContact(contact))
        default:
            break
        }
    }
}

extension SendCollectibleAccountListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        if query.isEmpty {
            dataController.resetSearch()
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }

    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        let qrScannerViewController = open(
            .qrScanner(
                canReadWCSession: false
            ),
            by: .push
        ) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

extension SendCollectibleAccountListViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        defer {
            completionHandler?()
        }
        
        guard let qrAddress = qrText.address,
              qrAddress.isValidatedAddress else {
                  return
              }

        searchInputView.setText(qrAddress)
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            completionHandler?()
        }
    }
}

extension SendCollectibleAccountListViewController {
    enum Event {
        case didSelectAccount(Account)
        case didSelectContact(Contact)
    }
}
