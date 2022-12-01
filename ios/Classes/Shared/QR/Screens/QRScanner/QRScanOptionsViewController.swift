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

//   QRScanOptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import UIKit

final class QRScanOptionsViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable,
    UIContextMenuInteractionDelegate {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private let copyToClipboardController: CopyToClipboardController

    private lazy var addressContextView = TripleShadowView()
    private lazy var addressTitleLabel = UILabel()
    private lazy var addressValueLabel = UILabel()
    private lazy var optionContextView = VStackView()

    private let theme = QRScanOptionsViewControllerTheme()
    private let address: PublicKey

    private lazy var addressMenuInteraction = UIContextMenuInteraction(delegate: self)

    init(
        address: PublicKey,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.address = address
        self.copyToClipboardController = copyToClipboardController
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        configureBackground()
    }

    override func bindData() {
        super.bindData()
        bindData(QRScanOptionsViewModel(address))
    }

    override func prepareLayout() {
        super.prepareLayout()
        addAddressContextView()
        addOptionContextView()
    }
}

extension QRScanOptionsViewController {
    private func configureBackground() {
        view.customizeAppearance(theme.background)
        title = "qr-scan-option-title".localized
    }

    private func bindData(_ viewModel: QRScanOptionsViewModel) {
        addressTitleLabel.editText = viewModel.title
        addressValueLabel.editText = viewModel.address
    }
}

extension QRScanOptionsViewController {
    private func addAddressContextView() {
        addressContextView.drawAppearance(shadow: theme.addressContainerFirstShadow)
        addressContextView.drawAppearance(secondShadow: theme.addressContainerSecondShadow)
        addressContextView.drawAppearance(thirdShadow: theme.addressContainerThirdShadow)

        addressContextView.addInteraction(addressMenuInteraction)

        contentView.addSubview(addressContextView)
        addressContextView.snp.makeConstraints {
            $0.setPaddings(theme.addressContextPaddings)
        }

        addAddressTitleLabel()
        addAddressValueLabel()
    }

    private func addAddressTitleLabel() {
        addressTitleLabel.customizeAppearance(theme.addressTitle)
        addressContextView.addSubview(addressTitleLabel)
        addressTitleLabel.snp.makeConstraints {
            $0.setPaddings(theme.addressTitlePaddings)
        }
    }

    private func addAddressValueLabel() {
        addressValueLabel.customizeAppearance(theme.addressValue)
        addressContextView.addSubview(addressValueLabel)
        addressValueLabel.snp.makeConstraints {
            $0.top == addressTitleLabel.snp.bottom + theme.addressValueOffset
            $0.setPaddings(theme.addressValuePaddings)
        }
    }

    private func addOptionContextView() {
        contentView.addSubview(optionContextView)
        optionContextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.optionContextPaddings.top,
            leading: theme.optionContextPaddings.leading,
            bottom: theme.optionContextPaddings.bottom,
            trailing: theme.optionContextPaddings.trailing
        )
        optionContextView.isLayoutMarginsRelativeArrangement = true
        optionContextView.snp.makeConstraints {
            $0.top == addressContextView.snp.bottom
            $0.setPaddings(
                (.noMetric, 0, 0, 0)
            )
        }

        let sendTransactionOptionView = addButton(
            QRSendTransactionOptionViewModel(),
            #selector(sendTransaction)
        )
        sendTransactionOptionView.addSeparator(
            theme.separator,
            padding: theme.separatorPadding
        )

        let addWatchAccountOptionView = addButton(
            QRAddWatchAccountOptionViewModel(),
            #selector(addWatchAccount)
        )
        addWatchAccountOptionView.addSeparator(
            theme.separator,
            padding: theme.separatorPadding
        )

        addButton(
            QRAddContactOptionViewModel(),
            #selector(addContact)
        )
    }

    @discardableResult
    private func addButton(
        _ viewModel: ListItemButtonViewModel,
        _ selector: Selector
    ) -> ListItemButton {
        let button = ListItemButton()

        button.customize(theme.button)
        button.bindData(viewModel)

        optionContextView.addArrangedSubview(button)

        button.addTouch(
            target: self,
            action: selector
        )

        return button
    }
}

extension QRScanOptionsViewController {
    @objc
    private func sendTransaction() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.transaction)
        }
    }

    @objc
    private func addWatchAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.watchAccount)
        }
    }

    @objc
    private func addContact() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.contact)
        }
    }
}

extension QRScanOptionsViewController {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                self.copyToClipboardController.copyAddress(self.address)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension QRScanOptionsViewController {
    enum Event {
        case transaction
        case watchAccount
        case contact
    }
}
