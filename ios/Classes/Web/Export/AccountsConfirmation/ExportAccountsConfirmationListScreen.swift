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

//   ExportAccountsConfirmationListScreen.swift

import UIKit
import MacaroonUIKit

final class ExportAccountsConfirmationListScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event, ExportAccountsConfirmationListScreen) -> Void

    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        listView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private lazy var theme = ExportAccountsConfirmationListScreenTheme()

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = ExportAccountsConfirmationListLayout.build()
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
    private lazy var continueActionView: LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator()
        loadingIndicator.applyStyle(theme.continueActionIndicator)
        return LoadingButton(loadingIndicator: loadingIndicator)
    }()

    private lazy var cancelActionView = MacaroonUIKit.Button()

    private lazy var listLayout = ExportAccountsConfirmationListLayout(listDataSource: listDataSource, hasSingularAccount: dataController.hasSingularAccount)
    private lazy var listDataSource = ExportAccountsConfirmationListDataSource(listView, hasSingularAccount: dataController.hasSingularAccount)

    private lazy var navigationBarLargeTitleController =
        NavigationBarLargeTitleController(screen: self)

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private var isLayoutFinalized = false

    private let dataController: ExportAccountsConfirmationListDataController

    init(
        dataController: ExportAccountsConfirmationListDataController,
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

        let title = dataController.hasSingularAccount ? "web-export-accounts-confirmation-list-title-singular".localized : "web-export-accounts-confirmation-list-title".localized

        navigationBarLargeTitleController.title = title
        navigationBarLargeTitleController.additionalScrollEdgeOffset = theme.listContentTopInset
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

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addList()
        addContinueActionViewGradient()
        addContinueActionView()
        addCancelActionView()
    }
}

extension ExportAccountsConfirmationListScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension ExportAccountsConfirmationListScreen {
    private func updateUIWhenViewDidLayout() {
        updateAdditionalSafeAreaInetsWhenViewDidLayout()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayout() {
        let inset =
        theme.spacingBetweenListAndContinueAction +
        continueActionView.frame.height +
        theme.spacingBetweenActions +
        cancelActionView.frame.height +
        theme.actionMargins.bottom

        additionalSafeAreaInsets.top = theme.navigationBarEdgeInset.top
        additionalSafeAreaInsets.bottom = inset
        listView.contentInset.top = navigationBarLargeTitleView.bounds.height + theme.listContentTopInset
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
        continueActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        continueActionView.snp.makeConstraints {
            $0.fitToHeight(theme.continueActionHeight)
            $0.top == theme.spacingBetweenListAndContinueAction
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
        }

        continueActionView.addTouch(
            target: self,
            action: #selector(performContinue)
        )
    }

    private func addCancelActionView() {
        cancelActionView.customizeAppearance(theme.cancelAction)

        continueActionEffectView.addSubview(cancelActionView)
        cancelActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        cancelActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.actionMargins.bottom

            $0.top == continueActionView.snp.bottom + theme.spacingBetweenListAndContinueAction
            $0.leading == theme.actionMargins.leading
            $0.bottom == bottom
            $0.trailing == theme.actionMargins.trailing
        }

        cancelActionView.addTouch(
            target: self,
            action: #selector(performCancel)
        )
    }
}

extension ExportAccountsConfirmationListScreen {
    func startLoading() {
        continueActionView.startLoading()
    }

    func stopLoading() {
        continueActionView.stopLoading()
    }
}

extension ExportAccountsConfirmationListScreen {
    @objc
    private func performContinue() {
        let accounts = dataController.selectedAccounts
        eventHandler?(.performContinue(with: accounts), self)
    }

    @objc
    private func performCancel() {
        eventHandler?(.performCancel, self)
    }
}

extension ExportAccountsConfirmationListScreen {
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

extension ExportAccountsConfirmationListScreen {
    enum Event {
        case performContinue(with: [Account])
        case performCancel
    }
}
