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

//   ReceiverAccountSelectionListScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils
import SnapKit

final class ReceiverAccountSelectionListScreen:
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
        let collectionViewLayout = ReceiverAccountSelectionListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = ReceiverAccountSelectionListLayout(listDataSource: listDataSource )
    private lazy var listDataSource = ReceiverAccountSelectionListDataSource(listView)

    private var clipboardStartLayout: [Constraint] = []
    private var clipboardEndLayout: [Constraint] = []

    private let dataController: ReceiverAccountSelectionListDataController
    private let theme: ReceiverAccountSelectionListScreenTheme

    init(
        dataController: ReceiverAccountSelectionListDataController,
        theme: ReceiverAccountSelectionListScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme

        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot, let isLoading):
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )

                self.searchInputView.isUserInteractionEnabled = !isLoading
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
        addBackground()
        addList()
        addClipboard()
        addSearchInput()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        displayClipboardIfNeeded()
    }
}

extension ReceiverAccountSelectionListScreen {
    private func linkPasteboardInteractors() {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapCopyAddress)
        )
        clipboardView.addGestureRecognizer(recognizer)

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
    private func displayClipboardIfNeeded() {
        let address = UIPasteboard.general.validAddress
        let shouldDisplayClipboard = address != nil

        if shouldDisplayClipboard {
            bindClipboard(address!)
        }

        updateLayoutWhenClipboardDisplayingStatusDidChange(isDisplaying: shouldDisplayClipboard)
    }

    private func updateLayoutWhenClipboardDisplayingStatusDidChange(isDisplaying: Bool) {
        updateClipboardLayoutBeforeAnimations(isDisplaying: isDisplaying)

        let animator = UIViewPropertyAnimator(
            duration: 0.2,
            curve: .easeInOut
        ) { [unowned self] in
            updateClipboardAlongsideAnimations(isDisplaying: isDisplaying)
            updateListLayoutWhenClipboardDisplayingStatusDidChange(isDisplaying: isDisplaying)

            view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    func updateClipboardLayoutBeforeAnimations(isDisplaying: Bool) {
        let currentLayout: [Constraint]
        let nextLayout: [Constraint]

        if isDisplaying {
            currentLayout = clipboardEndLayout
            nextLayout = clipboardStartLayout
        } else {
            currentLayout = clipboardStartLayout
            nextLayout = clipboardEndLayout
        }

        currentLayout.deactivate()
        nextLayout.activate()
    }

    func updateClipboardAlongsideAnimations(isDisplaying: Bool) {
        clipboardCanvasView.alpha = isDisplaying ? 1 : 0
    }

    func updateListLayoutWhenClipboardDisplayingStatusDidChange(isDisplaying: Bool) {
        let clipboardHeight = clipboardCanvasView.frame.height
        let contentInsetTop = clipboardHeight
        listView.contentInset.top = isDisplaying ? contentInsetTop : .zero

        listView.scrollToTop(animated: false)
    }

    @objc
    private func didTapCopyAddress() {
        if let address = UIPasteboard.general.validAddress {
            searchInputView.setText(address)
        }
    }
}

extension ReceiverAccountSelectionListScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addSearchInput() {
        searchInputView.customize(
            QRSearchInputViewTheme(
                placeholder: "account-select-header-search-title".localized,
                family: .current
            )
        )

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == theme.searchInputTopPadding
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }

        addSeachInputBackground()
    }

    private func addSeachInputBackground() {
        let backgroundView = GradientView()
        backgroundView.colors = [
            Colors.Defaults.background.uiColor,
            Colors.Defaults.background.uiColor.withAlphaComponent(0)
        ]

        view.insertSubview(
            backgroundView,
            belowSubview: searchInputView
        )
        backgroundView.snp.makeConstraints {
            let height = 20.0
            $0.fitToHeight(height)

            $0.top == searchInputView.snp.bottom
            $0.leading == searchInputView
            $0.trailing == searchInputView
        }
    }

    private func addClipboard() {
        view.addSubview(clipboardCanvasView)
        clipboardCanvasView.customizeAppearance(theme.background)

        clipboardCanvasView.snp.makeConstraints {
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }

        clipboardView.customize(theme.clipboard)
        clipboardCanvasView.addSubview(clipboardView)
        clipboardView.snp.makeConstraints {
            $0.setPaddings(theme.clipboardPaddings)
        }

        clipboardCanvasView.snp.prepareConstraints {
            clipboardStartLayout =  [
                $0.top ==
                theme.searchInputTopPadding +
                theme.searchInputHeight
            ]
            clipboardEndLayout = [
                $0.top == 0
            ]
        }

        updateClipboardLayoutBeforeAnimations(isDisplaying: false)
        updateClipboardAlongsideAnimations(isDisplaying: false)

        let someValidAddress = String(
            repeating: "A",
            count: validatedAddressLength
        )
        bindClipboard(someValidAddress)
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            let top = theme.searchInputTopPadding + theme.searchInputHeight
            $0.top == top
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension ReceiverAccountSelectionListScreen {
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

extension ReceiverAccountSelectionListScreen {
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

extension ReceiverAccountSelectionListScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        searchInputView.endEditing()

        switch itemIdentifier {
        case .account(let item, _):
            guard let address = item.address,
                  let account = dataController[accountAddress: address] else {
                return
            }

            eventHandler?(.didSelectAccount(account))
        case .accountGeneratedFromQuery:
            guard let account = dataController.accountGeneratedFromQuery else {
                return
            }

            eventHandler?(.didSelectAccount(account))
        case .contact(let item, _):
            guard let address = item.fullAddress,
                  let contact = dataController[contactAddress: address] else {
                return
            }

            eventHandler?(.didSelectContact(contact))
        case .nameServiceAccount(let item, _):
            guard let address = item.address,
                  let nameService = dataController[nameServiceAddress: address] else {
                return
            }

            eventHandler?(.didSelectNameService(nameService))
        default:
            break
        }
    }
}

extension ReceiverAccountSelectionListScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        let isLoading = !view.isUserInteractionEnabled

        guard !isLoading else {
            return
        }

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

extension ReceiverAccountSelectionListScreen: QRScannerViewControllerDelegate {
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

extension ReceiverAccountSelectionListScreen {
    private func bindClipboard(_ address: String) {
        let viewModel = AccountClipboardViewModel(address)
        clipboardView.bindData(viewModel)
    }
}

extension ReceiverAccountSelectionListScreen {
    enum Event {
        case didSelectAccount(Account)
        case didSelectContact(Contact)
        case didSelectNameService(NameService)
    }
}
