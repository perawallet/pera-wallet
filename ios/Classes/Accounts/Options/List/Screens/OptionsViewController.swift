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
//  OptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import MagpieExceptions
import UIKit

final class OptionsViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    weak var delegate: OptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var canvasView = UIView()
    private lazy var primaryContextView = VStackView()
    private lazy var secondaryContextView = VStackView()
    private lazy var tertiaryContextView = VStackView()
    
    private var muteNotificationsView: ListItemButton?

    private let account: Account
    private let optionGroup: OptionGroup
    
    private let theme: OptionsViewControllerTheme
    
    init(
        account: Account,
        configuration: ViewControllerConfiguration,
        theme: OptionsViewControllerTheme = .init()
    ) {
        self.account = account
        self.optionGroup = OptionGroup.makeOptionGroup(
            for: account,
            session: configuration.session!
        )
        self.theme = theme
        
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }
    
    private func addUI() {
        addBackground()
        addCanvas()
        addButtons()
    }
}

extension OptionsViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addCanvas() {
        contentView.addSubview(canvasView)
        canvasView.snp.makeConstraints {
            $0.top == theme.canvasPaddings.top
            $0.leading == theme.canvasPaddings.leading
            $0.bottom == theme.canvasPaddings.bottom
            $0.trailing == theme.canvasPaddings.trailing
        }

        addContext()
    }

    private func addContext() {
        addPrimaryContext()
        addSecondaryContext()

        if optionGroup.tertiaryOptions.isNonEmpty {
            addTertiaryContext()
        }
    }

    private func addButtons() {
        addButtons(
            optionGroup.primaryOptions,
            to: primaryContextView
        )
        addButtons(
            optionGroup.secondaryOptions,
            to: secondaryContextView
        )
        addButtons(
            optionGroup.tertiaryOptions,
            to: tertiaryContextView
        )
    }
    
    private func addPrimaryContext() {
        canvasView.addSubview(primaryContextView)
        primaryContextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.primaryContextPaddings.top,
            leading: theme.primaryContextPaddings.leading,
            bottom: theme.primaryContextPaddings.bottom,
            trailing: theme.primaryContextPaddings.trailing
        )
        primaryContextView.isLayoutMarginsRelativeArrangement = true
        primaryContextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSecondaryContext() {
        let separator = contentView.attachSeparator(
            theme.separator,
            to: primaryContextView,
            margin: theme.verticalPadding
        )

        canvasView.addSubview(secondaryContextView)
        secondaryContextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.secondaryContextPaddings.top,
            leading: theme.secondaryContextPaddings.leading,
            bottom: theme.secondaryContextPaddings.bottom,
            trailing: theme.secondaryContextPaddings.trailing
        )
        secondaryContextView.isLayoutMarginsRelativeArrangement = true
        secondaryContextView.snp.makeConstraints {
            $0.top == separator
            $0.leading == 0
            $0.bottom.equalToSuperview().priority(.medium)
            $0.trailing == 0
        }
    }

    private func addTertiaryContext() {
        let separator = contentView.attachSeparator(
            theme.separator,
            to: secondaryContextView,
            margin: theme.verticalPadding
        )

        canvasView.addSubview(tertiaryContextView)
        tertiaryContextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.tertiaryContextPaddings.top,
            leading: theme.tertiaryContextPaddings.leading,
            bottom: theme.tertiaryContextPaddings.bottom,
            trailing: theme.tertiaryContextPaddings.trailing
        )
        tertiaryContextView.isLayoutMarginsRelativeArrangement = true
        tertiaryContextView.snp.makeConstraints {
            $0.top == separator
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addButtons(
        _ options: [Option],
        to stackView: UIStackView
    ) {
        options.forEach {
            switch $0 {
            case .copyAddress:
                addButton(
                    CopyAddressListItemButtonViewModel(account),
                    #selector(copyAddress),
                    to: stackView
                )
            case .showAddress:
                addButton(
                    ShowQrCodeListItemButtonViewModel(),
                    #selector(showQRCode),
                    to: stackView
                )
            case .undoRekey:
                guard
                    let authAddress = account.authAddress,
                    let authAccount = sharedDataController.accountCollection.account(for: authAddress)
                else {
                    return
                }

                addButton(
                    UndoRekeyListItemButtonViewModel(authAccount: authAccount),
                    #selector(undoRekey),
                    to: stackView
                )
            case .rekeyToLedger:
                addButton(
                    RekeyToLedgerAccountListItemButtonViewModel(),
                    #selector(rekeyToLedgerAccount),
                    to: stackView
                )
            case .rekeyToStandardAccount:
                addButton(
                    RekeyToStandardAccountListItemButtonViewModel(),
                    #selector(rekeyToStandardAccount),
                    to: stackView
                )
            case .rekeyInformation:
                addButton(
                    RekeyAccountInformationListActionViewModel(),
                    #selector(showRekeyInformation),
                    to: stackView
                )
            case .viewPassphrase:
                addButton(
                    ViewPassphraseListItemButtonViewModel(),
                    #selector(viewPassphrase),
                    to: stackView
                )
            case .muteNotifications:
                muteNotificationsView = addButton(
                    MuteNotificationsListItemButtonViewModel(account),
                    #selector(muteNotifications),
                    to: stackView
                )
            case .renameAccount:
                addButton(
                    RenameAccountListItemButtonViewModel(),
                    #selector(renameAccount),
                    to: stackView
                )
            case .removeAccount:
                addButton(
                    RemoveAccountListItemButtonViewModel(),
                    #selector(removeAccount),
                    to: stackView
                )
            }
        }
    }
    
    @discardableResult
    private func addButton(
        _ viewModel: ListItemButtonViewModel,
        _ selector: Selector,
        to stackView: UIStackView
    ) -> ListItemButton {
        let button = ListItemButton()
        
        button.customize(theme.button)
        button.bindData(viewModel)
        
        stackView.addArrangedSubview(button)
        
        button.addTouch(
            target: self,
            action: selector
        )
        
        return button
    }
}

extension OptionsViewController {
    @objc
    private func copyAddress() {
        dismissScreen()
        delegate?.optionsViewControllerDidCopyAddress(self)
    }

    @objc
    private func undoRekey() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidUndoRekey(self)
        }
    }
    
    @objc
    private func rekeyToLedgerAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidOpenRekeyingToLedger(self)
        }
    }
    
    @objc
    private func rekeyToStandardAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidOpenRekeyingToStandardAccount(self)
        }
    }
    
    @objc
    private func showQRCode() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidShowQR(self)
        }
    }

    @objc
    private func showRekeyInformation() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidViewRekeyInformation(self)
        }
    }
    
    @objc
    private func viewPassphrase() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidViewPassphrase(self)
        }
    }
    
    @objc
    private func muteNotifications() {
        updateNotificationStatus()
    }
    
    @objc
    private func renameAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidRenameAccount(self)
        }
    }
    
    @objc
    private func removeAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidRemoveAccount(self)
        }
    }
}

extension OptionsViewController {
    private func updateNotificationStatus() {
        guard
            let network = api?.network,
            let deviceId = session?.authenticatedUser?.getDeviceId(on: network)
        else {
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        let draft = NotificationFilterDraft(
            deviceId: deviceId,
            accountAddress: account.address,
            receivesNotifications: !account.receivesNotification
        )

        api?.updateNotificationFilter(draft) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.didUpdateNotificationStatus(response)
            case .failure(_, let apiErrorDetail):
                self.didFailToUpdateNotificationStatus(apiErrorDetail)
            }
            
            self.loadingController?.stopLoading()
        }
    }

    private func didUpdateNotificationStatus(
        _ response: NotificationFilterResponse
    ) {
        account.receivesNotification = response.receivesNotification
        
        if let localAccount = session?.accountInformation(from: account.address) {
            localAccount.receivesNotification = response.receivesNotification
            session?.authenticatedUser?.updateAccount(localAccount)
        }

        muteNotificationsView?.bindData(MuteNotificationsListItemButtonViewModel(account))
    }

    private func didFailToUpdateNotificationStatus(
        _ apiErrorDetail: HIPAPIError?
    ) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: apiErrorDetail?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
    }
}

extension OptionsViewController {
    struct OptionGroup {
        let primaryOptions: [Option]
        let secondaryOptions: [Option]
        let tertiaryOptions: [Option]

        static func makeOptionGroup(
            for account: Account,
            session: Session
        ) -> OptionGroup {
            return account.authorization.isWatch
            ? makeOptionGroup(forWatchAccount: account)
            : makeOptionGroup(
                forNonWatchAccount: account,
                session: session
            )
        }

        private static func makeOptionGroup(
            forWatchAccount account: Account
        ) -> OptionGroup {
            var primaryOptions: [Option] = [
                .copyAddress,
                .showAddress
            ]
            
            if account.hasAuthAccount() {
                primaryOptions.append(.rekeyInformation)
            }

            let secondaryOptions: [Option] = [
                .renameAccount,
                .muteNotifications,
                .removeAccount
            ]
            return OptionGroup(
                primaryOptions: primaryOptions,
                secondaryOptions: secondaryOptions,
                tertiaryOptions: []
            )
        }

        private static func makeOptionGroup(
            forNonWatchAccount account: Account,
            session: Session
        ) -> OptionGroup {
            var primaryOptions: [Option] = []

            primaryOptions.append(.copyAddress)
            primaryOptions.append(.showAddress)

            if account.hasAuthAccount() {
                primaryOptions.append(.rekeyInformation)
            }
            
            if session.hasPrivateData(for: account.address) {
                primaryOptions.append(.viewPassphrase)
            }

            var secondaryOptions: [Option] = []
            var tertiaryOptions: [Option] = []

            if account.authorization.isNoAuth {
                secondaryOptions = [
                    .renameAccount,
                    .muteNotifications,
                    .removeAccount
                ]
            } else {
                if account.authorization.isRekeyed {
                    secondaryOptions.append(.undoRekey)
                }

                secondaryOptions.append(.rekeyToLedger)
                secondaryOptions.append(.rekeyToStandardAccount)

                tertiaryOptions = [
                    .renameAccount,
                    .muteNotifications,
                    .removeAccount
                ]
            }

            return OptionGroup(
                primaryOptions: primaryOptions,
                secondaryOptions: secondaryOptions,
                tertiaryOptions: tertiaryOptions
            )
        }
    }

    enum Option {
        case copyAddress
        case showAddress
        case undoRekey
        case rekeyToLedger
        case rekeyToStandardAccount
        case rekeyInformation
        case viewPassphrase
        case muteNotifications
        case renameAccount
        case removeAccount
    }
}

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidCopyAddress(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidShowQR(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidUndoRekey(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidOpenRekeyingToLedger(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidOpenRekeyingToStandardAccount(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidViewPassphrase(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidViewRekeyInformation(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRenameAccount(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRemoveAccount(
        _ optionsViewController: OptionsViewController
    )
}
