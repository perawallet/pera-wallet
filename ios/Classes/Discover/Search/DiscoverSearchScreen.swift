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

//   DiscoverSearchScreen.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import UIKit

final class DiscoverSearchScreen:
    BaseViewController,
    MacaroonForm.KeyboardControllerDataSource,
    UICollectionViewDelegateFlowLayout {

    typealias EventHandler = (Event, DiscoverSearchScreen) -> Void
    
    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool { false }

    private lazy var searchInputView: SearchInputView = .init()
    private lazy var searchInputBackgroundView: EffectView = .init()
    private lazy var cancelActionView: UIButton = .init()
    private lazy var listView: UICollectionView =
        .init(frame: .zero, collectionViewLayout: DiscoverSearchScreenLayout.build())

    private lazy var dataSource = DiscoverSearchDataSource(
        collectionView: listView,
        dataController: dataController
    )
    private lazy var listLayout = DiscoverSearchScreenLayout(
        listDataSource: dataSource,
        dataController: dataController
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var keyboardController =
        MacaroonForm.KeyboardController(scrollView: listView, screen: self)

    private var isViewLayoutLoaded = false

    private let dataController: DiscoverSearchDataController

    private let theme = DiscoverSearchScreenTheme()

    init(
        dataController: DiscoverSearchDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)

        startObservingDataChanges()

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
        updateUIWhenKeyboardDidToggle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            loadInitialData()
            isViewLayoutLoaded = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimatingLoadingIfNeededWhenViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }
}

/// <mark>
/// SearchInputViewDelegate
extension DiscoverSearchScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        loadRequestedData()
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension DiscoverSearchScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.listView(
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
        return listLayout.listView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

/// <mark>
/// UICollectionViewDelegate
extension DiscoverSearchScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .loading:
            startAnimatingListLoadingIfNeeded(cell)
        case .error:
            startObservingListErrorEvents(cell)
        case .nextLoading:
            startAnimatingNextListLoadingIfNeeded(cell)
        case .nextError:
            startObservingNextListErrorEvents(cell)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .loading:
            stopAnimatingListLoadingIfNeeded(cell)
        case .nextLoading:
            stopAnimatingNextListLoadingIfNeeded(cell)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .asset(let assetItem):
            handleSelectionOfCellForAssetItem(assetItem)
        default:
            break
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension DiscoverSearchScreen {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.bounds.height

        if contentHeight <= scrollHeight ||
           contentHeight - scrollView.contentOffset.y < 2 * scrollHeight {
            loadNextData()
        }
    }
}

extension DiscoverSearchScreen {
    private func addUI() {
        addBackground()
        addSearchInput()
        addCancelAction()
        addList()
    }

    private func updateUIWhenKeyboardDidToggle() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            if self.dataSource.isEmpty() {
                self.listView.collectionViewLayout.invalidateLayout()
                self.listView.layoutIfNeeded()
            }
        }
        keyboardController.performAlongsideWhenKeyboardIsHiding(animated: true) {
            [unowned self] _ in
            if self.dataSource.isEmpty() {
                self.listView.collectionViewLayout.invalidateLayout()
                self.listView.layoutIfNeeded()
            }
        }
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addSearchInput() {
        searchInputView.customize(theme.searchInput)

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == view.safeAreaLayoutGuide.snp.top + theme.contentTopEdgeInset
            $0.leading == theme.contentHorizontalEdgeInsets.leading
        }

        searchInputView.delegate = self

        searchInputBackgroundView.effect = theme.searchInputBackground
        searchInputBackgroundView.isUserInteractionEnabled = false

        view.insertSubview(
            searchInputBackgroundView,
            belowSubview: searchInputView
        )
        searchInputBackgroundView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == searchInputView + theme.spacingBetweenSearchInputAndSearchInputBackground
            $0.trailing == 0
        }
    }

    private func addCancelAction() {
        cancelActionView.customizeAppearance(theme.cancelAction)

        view.addSubview(cancelActionView)
        cancelActionView.contentEdgeInsets = theme.cancelActionContentEdgeInsets
        cancelActionView.fitToHorizontalIntrinsicSize()
        cancelActionView.snp.makeConstraints {
            $0.height == searchInputView
            $0.centerY == searchInputView
            $0.leading == searchInputView.snp.trailing + theme.spacingBetweenSearchInputAndCancelAction
            $0.trailing ==
                theme.contentHorizontalEdgeInsets.trailing -
                theme.cancelActionContentEdgeInsets.right
        }

        cancelActionView.addTouch(
            target: self,
            action: #selector(cancel)
        )
    }

    private func addList() {
        listView.customizeAppearance(theme.list)

        view.insertSubview(
            listView,
            belowSubview: searchInputBackgroundView
        )
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.keyboardDismissMode = .interactive
        listView.delegate = self
    }
}

extension DiscoverSearchScreen {
    private func startObservingListErrorEvents(_ cell: UICollectionViewCell) {
        let errorCell = cell as? DiscoverErrorCell
        errorCell?.startObserving(event: .retry) {
            [unowned self] in
            self.loadRequestedData()
        }
    }

    private func startObservingNextListErrorEvents(_ cell: UICollectionViewCell) {
        let errorCell = cell as? DiscoverSearchNextListErrorCell
        errorCell?.startObserving(event: .retry) {
            [unowned self] in
            self.loadNextData()
        }
    }
}

extension DiscoverSearchScreen {
    private func startAnimatingLoadingIfNeededWhenViewDidAppear() {
        if isViewFirstAppeared { return }

        for cell in listView.visibleCells {
            if let listLoadingCell = cell as? DiscoverSearchListLoadingCell {
                listLoadingCell.startAnimating()
                break
            }

            if let nextListLoadingCell = cell as? DiscoverSearchNextListLoadingCell {
                nextListLoadingCell.startAnimating()
                break
            }
        }
    }

    private func startAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchListLoadingCell
        loadingCell?.startAnimating()
    }

    private func startAnimatingNextListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchNextListLoadingCell
        loadingCell?.startAnimating()
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let listLoadingCell = cell as? DiscoverSearchListLoadingCell {
                listLoadingCell.stopAnimating()
                break
            }

            if let nextListLoadingCell = cell as? DiscoverSearchNextListLoadingCell {
                nextListLoadingCell.stopAnimating()
                break
            }
        }
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchListLoadingCell
        loadingCell?.stopAnimating()
    }

    private func stopAnimatingNextListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchNextListLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension DiscoverSearchScreen {
    @objc
    private func cancel() {
        closeScreen(by: .dismiss)
    }
}

extension DiscoverSearchScreen {
    private func startObservingDataChanges() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didReload(let snapshot):
                self.dataSource.reload(snapshot) {
                    [weak self] in
                    guard let self = self else { return }

                    self.listView.scrollToTop(animated: false)
                }
            case .didUpdate(let snapshot):
                self.dataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }
    }

    private func loadInitialData() {
        dataController.loadListData(query: nil)
    }

    private func loadRequestedData() {
        let keyword = searchInputView.text
        let query = keyword.unwrap(DiscoverSearchQuery.init)
        dataController.loadListData(query: query)
    }

    private func loadNextData() {
        dataController.loadNextListData()
    }
}

extension DiscoverSearchScreen {
    private func handleSelectionOfCellForAssetItem(_ item: DiscoverSearchAssetListItem) {
        let query = searchInputView.text
        let assetID = item.assetID
        let assetParameters = DiscoverAssetParameters(assetID: String(assetID))
        self.analytics.track(.searchDiscover(assetID: assetID, query: query))
        eventHandler?(.selectAsset(assetParameters), self)
    }
}

extension DiscoverSearchScreen {
    enum Event {
        case selectAsset(DiscoverAssetParameters)
    }
}
