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

//   WCSessionConnectionScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class WCSessionConnectionScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    BottomSheetPresentable {
    override var shouldShowNavigationBar: Bool {
        return false
    }

    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    var modalHeight: ModalHeight {
        return theme.calculateModalHeightAsBottomSheet(self)
    }
    
    let draft: WCSessionConnectionDraft
    
    private lazy var theme = WCSessionConnectionScreenTheme()

    private lazy var loadingView = InAppBrowserLoadingView()

    private(set) lazy var listView = UICollectionView(
        frame: .zero,
        collectionViewLayout: WCSessionConnectionListLayout.build()
    )
    private lazy var footerEffectView = EffectView()
    private lazy var actionsContextView = MacaroonUIKit.HStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var secondaryActionView = MacaroonUIKit.Button()

    private(set) lazy var listLayout = WCSessionConnectionListLayout(
        dataSource: dataSource,
        dataController: dataController
    )
    private(set) lazy var dataSource = WCSessionConnectionDataSource(
        collectionView: listView,
        dataController: dataController
    )

    private var isViewLayoutLoaded = false
    private var isAdditionalSafeAreaInsetsFinalized = false

    private let dataController: WCSessionConnectionDataController

    init(
        draft: WCSessionConnectionDraft,
        dataController: WCSessionConnectionDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.dataController = dataController
        super.init(configuration: configuration)

        startObservingDataUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty {
            return
        }

        if !isViewLayoutLoaded {
            loadInitialData()
            isViewLayoutLoaded = true
        }

        updateUIWhenViewDidLayoutSubviews()
    }
}

extension WCSessionConnectionScreen {
    private func startObservingDataUpdates() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didUpdate(let update):
                self.dataSource.apply(
                    update.snapshot,
                    to: update.section,
                    animatingDifferences: false
                )
                
            case .didFinishUpdates:
                self.updateUIWhenListDidFinishUpdates()
            }
        }
    }

    private func loadInitialData() {
        dataController.load()
    }
}

extension WCSessionConnectionScreen {
    private func updateUIWhenListDidFinishUpdates() {
        updateLayoutWhenListDidLoad()

        selectSingleAccountIfNeeded()
        togglePrimaryActionStateIfNeeded()

        performListUITransitionWhenListDidFinishUpdates()
    }

    private func performListUITransitionWhenListDidFinishUpdates() {
        let options: UIView.AnimationOptions = [
            .transitionCrossDissolve,
            .showHideTransitionViews
        ]
        UIView.transition(
            from: loadingView,
            to: listView,
            duration: 0.3,
            options: options
        )

        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }
}

extension WCSessionConnectionScreen {
    private func addUI() {
        addBackground()
        addList()
        addActions()
        addLoading()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addList() {
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.backgroundColor = .clear

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.delegate = self

        listView.isHidden = true
    }

    private func addActions() {
        addFooterGradient()
        addActionsContext()
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

    private func addActionsContext() {
        footerEffectView.addSubview(actionsContextView)

        actionsContextView.spacing = theme.spacingBetweenActions

        actionsContextView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.actionMargins.bottom

            $0.top == theme.spacingBetweenListAndPrimaryAction
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
            $0.bottom == bottom
        }

        addSecondaryAction()
        addPrimaryAction()
    }

    private func addSecondaryAction() {
        secondaryActionView.customizeAppearance(theme.secondaryAction)

        footerEffectView.addSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)

        actionsContextView.addArrangedSubview(secondaryActionView)

        secondaryActionView.addTouch(
            target: self,
            action: #selector(performSecondaryAction)
        )
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionsContextView.addArrangedSubview(primaryActionView)

        primaryActionView.snp.makeConstraints {
            $0.width == secondaryActionView * theme.secondaryActionWidthMultiplier
        }
        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        togglePrimaryActionStateIfNeeded()
    }

    private func addLoading() {
        loadingView.backgroundColor = Colors.Defaults.background.uiColor
        loadingView.isUserInteractionEnabled = false

        view.addSubview(loadingView)

        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        loadingView.startAnimating()
    }
}

extension WCSessionConnectionScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInsetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInsetsWhenViewDidLayoutSubviews() {
        if isAdditionalSafeAreaInsetsFinalized {
            return
        }

        if primaryActionView.bounds.isEmpty {
            return
        }

        let inset =
            theme.spacingBetweenListAndPrimaryAction +
            actionsContextView.frame.height +
            theme.actionMargins.bottom

        additionalSafeAreaInsets.bottom = inset

        isAdditionalSafeAreaInsetsFinalized = true
    }
}

extension WCSessionConnectionScreen {
    private func updateLayoutWhenListDidLoad() {
        listView.layoutIfNeeded()

        performLayoutUpdates(animated: true)
    }
}

extension WCSessionConnectionScreen {
    @objc
    private func performPrimaryAction() {
        let selectedAccountAddresses = dataController.getSelectedAccounts().map(\.address)
        eventHandler?(.performConnect(accounts: selectedAccountAddresses))
    }

    @objc
    private func performSecondaryAction() {
        eventHandler?(.performCancel)
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension WCSessionConnectionScreen {
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

/// <mark>
/// UICollectionViewDelegate
extension WCSessionConnectionScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .account:
            toggleAccountSelection(at: indexPath)
            togglePrimaryActionStateIfNeeded()
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .profile:
            startObservingProfileEvents(cell)
        case .account:
            startObservingAccountEvents(
                cell: cell,
                indexPath: indexPath
            )
        default:
            break
        }
    }
}

extension WCSessionConnectionScreen {
    private func startObservingProfileEvents(_ cell: UICollectionViewCell) {
        let profileCell = cell as? WCSessionConnectionProfileCell
        profileCell?.startObserving(event: .didTapLink) {
            [unowned self] in
            let link = draft.dappURL
            open(link)
        }
    }

    private func startObservingAccountEvents(
        cell: UICollectionViewCell,
        indexPath: IndexPath
    ) {
        guard let cell = cell as? WCSessionConnectionAccountCell else { return }

        let numberOfItemsInSection = listView.numberOfItems(inSection: indexPath.section)
        let lastItemIndex = numberOfItemsInSection - 1
        let isLastItem = lastItemIndex == indexPath.row
        if isLastItem {
            cell.removeSeparatorIfNeeded()
        }

        guard !dataController.hasSingleAccount else {
            cell.accessory = .selected
            return
        }

        let index = indexPath.row
        let isSelected = dataController.isAccountSelected(at: index)

        cell.accessory = isSelected ? .selected : .unselected
    }
}

extension WCSessionConnectionScreen {
    private func toggleAccountSelection(
        at indexPath: IndexPath
    ) {
        guard !dataController.hasSingleAccount else {
            return
        }

        let cell = listView.cellForItem(at: indexPath) as! WCSessionConnectionAccountCell
        let index = indexPath.row
        let isSelected = cell.accessory == .selected

        cell.accessory.toggle()

        if isSelected {
            dataController.unselectAccountItem(at: index)
        } else {
            dataController.selectAccountItem(at: index)
        }
    }

    private func selectSingleAccountIfNeeded() {
        if dataController.hasSingleAccount {
            dataController.selectAccountItem(at: .zero)
            togglePrimaryActionStateIfNeeded()
        }
    }

    private func togglePrimaryActionStateIfNeeded() {
        primaryActionView.isEnabled = dataController.isPrimaryActionEnabled
    }
}

extension WCSessionConnectionScreen {
    enum Event {
        case performCancel
        case performConnect(accounts: [PublicKey])
    }
}
