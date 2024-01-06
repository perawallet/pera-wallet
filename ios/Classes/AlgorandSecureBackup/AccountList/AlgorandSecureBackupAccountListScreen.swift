// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupAccountListScreen.swift

import UIKit
import MacaroonUIKit

class AlgorandSecureBackupAccountListScreen:
    BaseViewController,
    NavigationBarLargeTitleConfigurable,
    UICollectionViewDelegateFlowLayout {

    typealias EventHandler = (Event, AlgorandSecureBackupAccountListScreen) -> Void

    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        listView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    fileprivate private(set) lazy var theme = AlgorandSecureBackupAccountListScreenTheme()

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AlgorandSecureBackupAccountListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var continueActionEffectView = EffectView()
    fileprivate private(set) lazy var continueActionView = MacaroonUIKit.Button()

    private lazy var listLayout = AlgorandSecureBackupAccountListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = AlgorandSecureBackupAccountListDataSource(listView)

    fileprivate private(set) lazy var navigationBarLargeTitleController =
    NavigationBarLargeTitleController(screen: self)

    private var isLayoutFinalized = false

    fileprivate let dataController: AlgorandSecureBackupAccountListDataController

    init(
        dataController: AlgorandSecureBackupAccountListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController

        super.init(configuration: configuration)
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        navigationBarLargeTitleController.additionalScrollEdgeOffset = theme.listContentTopInset

        configureNavigationBarTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: false
                )
                self.selectAllAccountsIfNeeded()
            }
        }

        dataController.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized ||
            continueActionView.bounds.isEmpty {
            return
        }

        updateUIWhenViewDidLayout()

        isLayoutFinalized = true
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
        navigationBarLargeTitleController.activate()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    func bindContinueActionTitle() { }

    func configureNavigationBarTitle() { }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addList()
        addContinueActionViewGradient()
        addContinueActionView()
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }
}

extension AlgorandSecureBackupAccountListScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension AlgorandSecureBackupAccountListScreen {
    private func updateUIWhenViewDidLayout() {
        updateAdditionalSafeAreaInetsWhenViewDidLayout()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayout() {
        let inset =
            theme.spacingBetweenListAndContinueAction +
            continueActionView.frame.height +
            theme.continueActionContentEdgeInsets.bottom
        additionalSafeAreaInsets.bottom = inset

        listView.contentInset.top = navigationBarLargeTitleView.bounds.height + theme.listContentTopInset
    }

    private func toggleContinueActionStateIfNeeded() {
        continueActionView.isEnabled = dataController.isContinueActionEnabled

        bindContinueActionTitle()
    }

    private func addContinueActionViewGradient() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        continueActionEffectView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(continueActionEffectView)
        continueActionEffectView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addContinueActionView() {
        continueActionView.customizeAppearance(theme.continueAction)

        continueActionEffectView.addSubview(continueActionView)
        continueActionView.contentEdgeInsets = UIEdgeInsets(theme.continueActionEdgeInsets)
        continueActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.continueActionContentEdgeInsets.bottom

            $0.top == theme.spacingBetweenListAndContinueAction
            $0.leading == theme.continueActionContentEdgeInsets.leading
            $0.bottom == bottom
            $0.trailing == theme.continueActionContentEdgeInsets.trailing
        }

        continueActionView.addTouch(
            target: self,
            action: #selector(performContinue)
        )

        toggleContinueActionStateIfNeeded()
    }

    @objc
    private func performContinue() {
        let selectedAccounts = dataController.getSelectedAccounts()
        eventHandler?(.performContinue(with: selectedAccounts), self)
    }
}

extension AlgorandSecureBackupAccountListScreen {
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

extension AlgorandSecureBackupAccountListScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let item):
            switch item {
            case .cell:
                toggleAccountSelection(at: indexPath)

                updateAccountsHeaderIfNeeded()
                toggleContinueActionStateIfNeeded()
            case .header:
                break
            }
        case .noContent:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let item):
            switch item {
            case .header:
                self.collectionView(
                    collectionView,
                    willDisplay: cell as! AlgorandSecureBackupAccountListAccountsHeader,
                    forItemAt: indexPath
                )
            case .cell:
                self.collectionView(
                    collectionView,
                    willDisplay: cell as! AlgorandSecureBackupAccountListAccountCell,
                    forItemAt: indexPath
                )
            }
        case .noContent:
            break
        }
    }
}

extension AlgorandSecureBackupAccountListScreen {
    private func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: AlgorandSecureBackupAccountListAccountsHeader,
        forItemAt indexPath: IndexPath
    ) {
        cell.state = dataController.getAccountsHeaderItemState()

        cell.startObserving(event: .performAction) {
            [unowned self] in

            let headerState = dataController.getAccountsHeaderItemState()

            switch headerState {
            case .selectAll, .partialSelection:
                selectAllAccounts()
            case .unselectAll:
                unselectAllAccounts()
            }

            updateAccountsHeaderIfNeeded()
            toggleContinueActionStateIfNeeded()
        }
    }

    private func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: AlgorandSecureBackupAccountListAccountCell,
        forItemAt indexPath: IndexPath
    ) {
        guard !dataController.hasSingleAccount else {
            cell.accessory = .none
            return
        }

        let index = indexPath.row.advanced(by: -1)
        let isSelected = dataController.isAccountSelected(at: index)

        cell.accessory = isSelected ? .selected : .unselected
    }
}

extension AlgorandSecureBackupAccountListScreen {
    func updateAccountsHeaderIfNeeded() {
        let itemIdentifier: AlgorandSecureBackupAccountListItemIdentifier = .account(.header(dataController.accountsHeaderViewModel))

        guard let indexPath = listDataSource.indexPath(for: itemIdentifier) else {
            return
        }

        guard let cell = listView.cellForItem(at: indexPath) as? AlgorandSecureBackupAccountListAccountsHeader else {
            return
        }

        cell.state = dataController.getAccountsHeaderItemState()
    }
}

extension AlgorandSecureBackupAccountListScreen {
    private func selectAllAccountsIfNeeded() {
        if dataController.hasSingleAccount {
            dataController.selectAllAccountsItems()
            toggleContinueActionStateIfNeeded()
        }
    }

    private func selectAllAccounts() {
        listView.indexPathsForVisibleItems.forEach { indexPath in
            let item = listDataSource.itemIdentifier(for: indexPath)

            if case .account(.cell) = item {
                selectAccount(at: indexPath)
            }
        }

        dataController.selectAllAccountsItems()
    }

    private func selectAccount(
        at indexPath: IndexPath
    ) {
        let cell = listView.cellForItem(at: indexPath) as! AlgorandSecureBackupAccountListAccountCell
        cell.accessory = .selected
    }

    private func unselectAllAccounts() {
        listView.indexPathsForVisibleItems.forEach { indexPath in
            let item = listDataSource.itemIdentifier(for: indexPath)

            if case .account(.cell) = item {
                unselectAccount(at: indexPath)
            }
        }

        dataController.unselectAllAccountsItems()
    }

    private func unselectAccount(
        at indexPath: IndexPath
    ) {
        let cell = listView.cellForItem(at: indexPath) as! AlgorandSecureBackupAccountListAccountCell
        cell.accessory = .unselected
    }

    private func toggleAccountSelection(
        at indexPath: IndexPath
    ) {
        guard !dataController.hasSingleAccount else {
            return
        }

        let cell = listView.cellForItem(at: indexPath) as! AlgorandSecureBackupAccountListAccountCell
        let index = indexPath.row.advanced(by: -1)
        let isSelected = cell.accessory == .selected

        cell.accessory.toggle()

        if isSelected {
            dataController.unselectAccountItem(at: index)
            return
        }

        dataController.selectAccountItem(at: index)
    }
}

extension AlgorandSecureBackupAccountListScreen {
    enum Event {
        case performContinue(with: [Account])
    }
}

final class AlgorandSecureBackupAccountRecoverListScreen: AlgorandSecureBackupAccountListScreen {
    override func configureNavigationBarTitle() {
        navigationBarLargeTitleController.title = "algorand-secure-backup-account-list-restore-title".localized
    }
    override func bindContinueActionTitle() {
        bindContinueActionTitleForRestore()
    }

    private func bindContinueActionTitleForRestore() {
        let selectedAccounts = dataController.getSelectedAccounts()
        let selectedAccountsCount = selectedAccounts.count

        let style = theme.continueActionForRestore(accountCount: selectedAccountsCount)

        continueActionView.customizeAppearance(style)
    }
}

final class AlgorandSecureBackupAccountExportListScreen: AlgorandSecureBackupAccountListScreen {
    override func configureNavigationBarTitle() {
        navigationBarLargeTitleController.title = "algorand-secure-backup-account-list-title".localized
    }

    override func bindContinueActionTitle() {
        bindContinueActionTitleForExport()
    }

    private func bindContinueActionTitleForExport() {
        let selectedAccounts = dataController.getSelectedAccounts()
        let selectedAccountsCount = selectedAccounts.count

        let style = theme.continueActionForExport(accountCount: selectedAccountsCount)

        continueActionView.customizeAppearance(style)
    }
}
