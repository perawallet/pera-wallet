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

//   WCConnectionScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class WCConnectionScreen:
    BaseViewController,
    BottomSheetPresentable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private(set) var modalHeight: ModalHeight = .compressed
    
    private lazy var theme = WCConnectionScreenTheme()
    
    private(set) lazy var contextView = WCConnectionView()
    private(set) lazy var bottomContainerView = EffectView()
    private lazy var actionsStackView = UIStackView()
    private lazy var cancelActionView = MacaroonUIKit.Button()
    private lazy var connectActionView = MacaroonUIKit.Button()

    private lazy var listLayout = WCConnectionAccountListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = WCConnectionAccountListDataSource(contextView.accountListView)

    private let walletConnectSessionConnectionCompletionHandler: WalletConnectSessionConnectionCompletionHandler

    let walletConnectSession: WalletConnectSession
    let dataController: WCConnectionAccountListDataController

    init(
        walletConnectSession: WalletConnectSession,
        walletConnectSessionConnectionCompletionHandler: @escaping WalletConnectSessionConnectionCompletionHandler,
        dataController: WCConnectionAccountListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.walletConnectSession = walletConnectSession
        self.walletConnectSessionConnectionCompletionHandler = walletConnectSessionConnectionCompletionHandler
        self.dataController = dataController

        super.init(configuration: configuration)
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
                self.bindUIData()
                
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: false
                )

                self.updateUILayout()
                self.selectSingleAccountIfNeeded()
            }
        }
        
        dataController.load()
    }
    
    override func setListeners() {
        super.setListeners()

        contextView.accountListView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addBackground()
        addContext()
        addBottomContainer()
    }
}

extension WCConnectionScreen {
    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    private func addContext() {
        contextView.customize(theme.contextView)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom == view.safeAreaBottom
        }
    }
    
    private func addBottomContainer() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        bottomContainerView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(bottomContainerView)
        bottomContainerView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == view.safeAreaBottom
            $0.trailing == 0
        }
        
        addActions()
    }
    
    private func addActions() {
        actionsStackView.distribution = .fillEqually
        actionsStackView.axis = .horizontal
        actionsStackView.spacing = theme.actionsStackViewSpacing
        
        addCancelAction()
        addConnectAction()
        
        bottomContainerView.addSubview(actionsStackView)
        actionsStackView.snp.makeConstraints {
            $0.leading.trailing == theme.actionsHorizontalPadding
            $0.bottom.top == theme.actionsVerticalPadding
        }
    }
    
    private func addCancelAction() {
        cancelActionView.customizeAppearance(theme.cancelAction)
        cancelActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionsStackView.addArrangedSubview(cancelActionView)
        
        cancelActionView.addTouch(
            target: self,
            action: #selector(performCancel)
        )
    }
    
    private func addConnectAction() {
        connectActionView.customizeAppearance(theme.connectAction)
        connectActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionsStackView.addArrangedSubview(connectActionView)
        
        connectActionView.addTouch(
            target: self,
            action: #selector(performConnect)
        )
        
        updateButtonState()
    }
}

extension WCConnectionScreen {
    private func bindUIData() {
        let viewModel = WCConnectionViewModel(
            session: walletConnectSession,
            hasSingleAccount: dataController.hasSingleAccount
        )
        contextView.bindData(viewModel)
        
        updateButtonState()
        
        contextView.startObserving(event: .openUrl) {
            [unowned self] in
            self.open(walletConnectSession.dAppInfo.peerMeta.url)
        }
    }
    
    private func updateUILayout() {
        contextView.accountListView.setContentInset(
            bottom: bottomContainerView.bounds.height
        )
        
        modalHeight = theme.calculateModalHeightAsBottomSheet(self)
        performLayoutUpdates(animated: isViewAppeared)
    }
    
    private func updateButtonState() {
        if dataController.isConnectActionEnabled {
            connectActionView.isEnabled = true
            return
        }
        
        connectActionView.isEnabled = false
    }
    
    private func selectSingleAccountIfNeeded() {
        if dataController.hasSingleAccount {
            toggleTheSingleAccountCell()
            updateButtonState()
        }
    }
}

extension WCConnectionScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            contextView.accountListView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        toggleAccountCell(at: indexPath)
        updateButtonState()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? ExportAccountListAccountCell else {
            return
        }
        
        let isSelected = dataController.isAccountSelected(at: indexPath.row)
        
        cell.accessory = isSelected ? .selected : .unselected
    }
    
    private func toggleAccountCell(at indexPath: IndexPath) {
        guard !dataController.hasSingleAccount else {
            return
        }
        
        let cell = contextView.accountListView.cellForItem(at: indexPath) as! ExportAccountListAccountCell
        let isSelected = cell.accessory == .selected
        
        cell.accessory.toggle()
        
        if isSelected {
            dataController.unselectAccountItem(at: indexPath.row)
            return
        }
        
        dataController.selectAccountItem(at: indexPath.row)
    }
    
    private func toggleTheSingleAccountCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = contextView.accountListView.cellForItem(at: indexPath) as? ExportAccountListAccountCell else {
            return
        }
        
        cell.accessory = .selected
        
        dataController.selectAccountItem(at: indexPath.row)
    }
}

extension WCConnectionScreen {
    @objc
    private func performCancel() {
        analytics.track(
            .wcSessionRejected(
                topic: walletConnectSession.url.topic,
                dappName: walletConnectSession.dAppInfo.peerMeta.name,
                dappURL: walletConnectSession.dAppInfo.peerMeta.url.absoluteString
            )
        )

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }

            self.walletConnectSessionConnectionCompletionHandler(
                self.walletConnectSession.getDeclinedWalletConnectionInfo(on: self.api!.network)
            )
            self.eventHandler?(.performCancel)
        }
    }
    
    @objc
    private func performConnect() {
        let selectedAccountAddresses = dataController.getSelectedAccountsAddresses()
                
        analytics.track(
            .wcSessionApproved(
                topic: walletConnectSession.url.topic,
                dappName: walletConnectSession.dAppInfo.peerMeta.name,
                dappURL: walletConnectSession.dAppInfo.peerMeta.url.absoluteString,
                address: selectedAccountAddresses.joined(separator: ","),
                totalAccount: selectedAccountAddresses.count
            )
        )
        
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }

            self.walletConnectSessionConnectionCompletionHandler(
                self.walletConnectSession.getApprovedWalletConnectionInfo(
                    for: selectedAccountAddresses,
                    on: self.api!.network
                )
            )
            self.eventHandler?(.performConnect)
        }
    }
}

extension WCConnectionScreen {
    enum Event {
        case performCancel
        case performConnect
    }
}
