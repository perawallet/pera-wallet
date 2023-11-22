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

//   RekeyedAccountSelectionListScreen.swift

import UIKit
import MacaroonUIKit

final class RekeyedAccountSelectionListScreen:
    BaseViewController,
    NavigationBarLargeTitleConfigurable,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event, RekeyedAccountSelectionListScreen) -> Void

    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return listView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private lazy var theme = RekeyedAccountSelectionListScreenTheme()

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = RekeyedAccountSelectionListNavigationBarView()

    private lazy var listView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: RekeyedAccountSelectionListLayout.build()
    )

    private lazy var footerEffectView = EffectView()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var secondaryActionView = MacaroonUIKit.Button()

    private lazy var listLayout = RekeyedAccountSelectionListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = RekeyedAccountSelectionListDataSource(
        listView,
        listHeader: makeListHeader()
    )

    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private var isLayoutFinalized = false

    private let dataController: RekeyedAccountSelectionListDataController

    init(
        dataController: RekeyedAccountSelectionListDataController,
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

        let theme = RekeyedAccountSelectionListNavigationBarViewTheme()
        navigationBarLargeTitleView.customize(theme)

        let accounts = dataController.getAccounts()
        let viewModel = RekeyedAccountSelectionListNavigationBarViewModel(accounts: accounts)
        navigationBarLargeTitleView.bindData(viewModel)
        navigationBarLargeTitleController.title = viewModel.title?.string
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
                    animatingDifferences: self.isViewAppeared
                )
                self.togglePrimaryActionStateIfNeeded()
                self.selectAllAccountsIfNeeded()
            }
        }

        dataController.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startAnimatingLoadingIfNeededWhenViewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized ||
           primaryActionView.bounds.isEmpty {
            return
        }

        updateUIWhenViewDidLayoutSubviews()

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

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addList()
        addActions()
    }
}

extension RekeyedAccountSelectionListScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(theme.navigationBarEdgeInset)
        }
    }

    private func addList() {
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.backgroundColor = .clear

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addActions() {
        addFooterGradient()
        addPrimaryAction()
        addSecondaryAction()
    }

    private func addFooterGradient() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        footerEffectView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(footerEffectView)
        footerEffectView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        footerEffectView.addSubview(primaryActionView)
        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        primaryActionView.snp.makeConstraints {
            $0.top == theme.spacingBetweenListAndPrimaryAction
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        togglePrimaryActionStateIfNeeded()
    }

    private func addSecondaryAction() {
        secondaryActionView.customizeAppearance(theme.secondaryAction)

        footerEffectView.addSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        secondaryActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.actionMargins.bottom

            $0.top == primaryActionView.snp.bottom + theme.spacingBetweenListAndPrimaryAction
            $0.leading == theme.actionMargins.leading
            $0.bottom == bottom
            $0.trailing == theme.actionMargins.trailing
        }

        secondaryActionView.addTouch(
            target: self,
            action: #selector(performSecondaryAction)
        )
    }
}

extension RekeyedAccountSelectionListScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInsetsWhenViewDidLayout()
    }

    private func updateAdditionalSafeAreaInsetsWhenViewDidLayout() {
        let inset =
            theme.spacingBetweenListAndPrimaryAction +
            primaryActionView.frame.height +
            theme.spacingBetweenActions +
            secondaryActionView.frame.height +
            theme.actionMargins.bottom

        additionalSafeAreaInsets.top = theme.navigationBarEdgeInset.top
        additionalSafeAreaInsets.bottom = inset
        
        listView.contentInset.top = navigationBarLargeTitleView.bounds.height
    }
}

extension RekeyedAccountSelectionListScreen {
    @objc
    private func performPrimaryAction() {
        let selectedAccounts = dataController.getSelectedAccounts()
        addAccounts(selectedAccounts)

        pushNotificationController.sendDeviceDetails()

        eventHandler?(.performPrimaryAction, self)
    }

    @objc
    private func performSecondaryAction() {
        eventHandler?(.performSecondaryAction, self)
    }
}

extension RekeyedAccountSelectionListScreen {
    private func addAccounts(_ accounts: [Account]) {
        guard let user = session?.authenticatedUser else { return }

        accounts.forEach { account in
            let account = AccountInformation(
                address: account.address,
                name: account.address,
                isWatchAccount: false,
                preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
                isBackedUp: true
            )

            if user.account(address: account.address) != nil {
                user.updateAccount(account)
            } else {
                user.addAccount(account)
            }

            analytics.track(.registerAccount(registrationType: .rekeyed))
        }

        session?.authenticatedUser = user
    }
}

extension RekeyedAccountSelectionListScreen {
    private func startAnimatingLoadingIfNeededWhenViewWillAppear() {
        if isViewFirstAppeared { return }

        for cell in listView.visibleCells {
            if let accountLoadingCell = cell as? RekeyedAccountSelectionListAccountLoadingCell {
                startAnimatingListLoadingIfNeeded(accountLoadingCell)
                return
            }
        }
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let accountLoadingCell = cell as? RekeyedAccountSelectionListAccountLoadingCell {
                stopAnimatingListLoadingIfNeeded(accountLoadingCell)
                return
            }
        }
    }
}

extension RekeyedAccountSelectionListScreen {
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
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
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

extension RekeyedAccountSelectionListScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account:
            toggleAccountSelection(at: indexPath)

            togglePrimaryActionStateIfNeeded()
        default: break
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
        case .accountLoading:
            self.collectionView(
                collectionView,
                willDisplay: cell as! RekeyedAccountSelectionListAccountLoadingCell,
                forItemAt: indexPath
            )
        case .account:
            self.collectionView(
                collectionView,
                willDisplay: cell as! RekeyedAccountSelectionListAccountCell,
                forItemAt: indexPath
            )
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
        case .accountLoading:
            self.collectionView(
                collectionView,
                didEndDisplaying: cell as! RekeyedAccountSelectionListAccountLoadingCell,
                forItemAt: indexPath
            )
        default: break
        }
    }
}

extension RekeyedAccountSelectionListScreen {
    private func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: RekeyedAccountSelectionListAccountCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.startObserving(event: .info) {
            [unowned self] in
            let itemIdentifier = self.listDataSource.itemIdentifier(for: indexPath)

            guard case .account(let item) = itemIdentifier else {
                return
            }

            let account = item.model
            self.openAccountDetail(account)
        }

        guard !dataController.hasSingleAccount else {
            cell.accessory = .selected
            return
        }

        let index = indexPath.row
        let isSelected = dataController.isAccountSelected(at: index)

        cell.accessory = isSelected ? .selected : .unselected
    }

    private func openAccountDetail(_ account: Account) {
        open(
            .ledgerAccountDetail(
                account: account,
                authAccount: dataController.authAccount,
                ledgerIndex: nil,
                rekeyedAccounts: nil
            ),
            by: .present
        )
    }
}

extension RekeyedAccountSelectionListScreen {
    private func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: RekeyedAccountSelectionListAccountLoadingCell,
        forItemAt indexPath: IndexPath
    ) {
        startAnimatingListLoadingIfNeeded(cell)
    }

    private func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: RekeyedAccountSelectionListAccountLoadingCell,
        forItemAt indexPath: IndexPath
    ) {
        stopAnimatingListLoadingIfNeeded(cell)
    }

    private func startAnimatingListLoadingIfNeeded(_ cell: RekeyedAccountSelectionListAccountLoadingCell?) {
        cell?.startAnimating()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: RekeyedAccountSelectionListAccountLoadingCell?) {
        cell?.stopAnimating()
    }
}

extension RekeyedAccountSelectionListScreen {
    private func selectAllAccountsIfNeeded() {
        if dataController.hasSingleAccount {
            dataController.selectAccountItem(at: .zero)
            togglePrimaryActionStateIfNeeded()
        }
    }
    
    private func toggleAccountSelection(
        at indexPath: IndexPath
    ) {
        guard !dataController.hasSingleAccount else {
            return
        }

        let cell = listView.cellForItem(at: indexPath) as! RekeyedAccountSelectionListAccountCell
        let index = indexPath.row
        let isSelected = cell.accessory == .selected

        cell.accessory.toggle()

        if isSelected {
            dataController.unselectAccountItem(at: index)
            return
        }

        dataController.selectAccountItem(at: index)
    }

    private func togglePrimaryActionStateIfNeeded() {
        primaryActionView.isEnabled = dataController.isPrimaryActionEnabled

        bindPrimaryActionTitle()
    }

    private func bindPrimaryActionTitle() {
        let selectedAccounts = dataController.getSelectedAccounts()
        let selectedAccountsCount = selectedAccounts.count

        let title: String

        /// <todo>:
        /// Support singular/plural localization properly.
        if selectedAccountsCount == 0 {
            title = "rekeyed-account-selection-list-primary-action-title".localized
        } else if selectedAccountsCount == 1 {
            title = "rekeyed-account-selection-list-primary-action-title-singular".localized
        } else {
            title = "rekeyed-account-selection-list-primary-action-title-plural".localized(params: "\(selectedAccountsCount)")
        }

        primaryActionView.editTitle = .string(title)
    }
}

extension RekeyedAccountSelectionListScreen {
    private func makeListHeader() -> RekeyedAccountSelectionListHeaderViewModel {
        let accounts = dataController.getAccounts()
        return .init(accounts: accounts)
    }
}

extension RekeyedAccountSelectionListScreen {
    enum Event {
        case performPrimaryAction
        case performSecondaryAction
    }
}
