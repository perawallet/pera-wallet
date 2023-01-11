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
//  RenameAccountScreen.swift

import Foundation
import UIKit
import MacaroonBottomSheet
import MacaroonForm
import MacaroonUIKit

final class RenameAccountScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable,
    MacaroonForm.KeyboardControllerDataSource {
    weak var delegate: RenameAccountScreenDelegate?

    var modalBottomPadding: LayoutMetric {
        return bottomInsetUnderKeyboardWhenKeyboardDidShow(keyboardController)
    }

    let modalHeight: MacaroonUIKit.ModalHeight = .compressed

    private lazy var theme = RenameAccountScreenTheme()

    private lazy var nameInputView = FloatingTextInputFieldView()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private let account: Account

    init(
        account: Account,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        bindNavigationTitle()
        addNavigationActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureKeyboardController()
        addUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameInputView.beginEditing()
    }
}

extension RenameAccountScreen {
    private func addUI() {
        addBackground()
        addNameInput()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNameInput() {
        nameInputView.customize(theme.nameInput)

        contentView.addSubview(nameInputView)
        nameInputView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.greaterThanHeight(theme.nameInputMinHeight)
        }

        nameInputView.delegate = self

        bindNameInput()
    }
}

extension RenameAccountScreen {
    private func bindNavigationTitle() {
        navigationItem.title = "options-edit-account-name".localized
    }

    private func addNavigationActions() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) {
            [unowned self] in
            self.didTapDoneButton()
        }

        rightBarButtonItems = [ doneBarButtonItem ]
    }
}

extension RenameAccountScreen {
     private func bindNameInput() {
         nameInputView.text = account.name
     }
 }

extension RenameAccountScreen: FloatingTextInputFieldViewDelegate {
     func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
         didTapDoneButton()
         return true
     }
 }

extension RenameAccountScreen {
    private func didTapDoneButton() {
        renameAccount()

        delegate?.renameAccountScreenDidTapDoneButton(self)
    }

    private func renameAccount() {
        lazy var fallbackName = account.address.shortAddressDisplay
        let accountName = nameInputView.text.unwrapNonEmptyString() ?? fallbackName

        /// <note>
        /// Since the syncing is always running, the references of the cached accounts may change
        /// at this moment. Let's be sure we can switch to the new name immediately.
        let cachedAccount = sharedDataController.accountCollection[account.address]?.value
        cachedAccount?.name = accountName

        account.name = accountName
        session?.updateName(accountName, for: account.address)
    }
}

/// <mark>
/// MacaroonForm.KeyboardControllerDataSource
extension RenameAccountScreen {
    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return keyboardController.keyboard?.height ?? 0
    }
}

extension RenameAccountScreen {
    private func configureKeyboardController() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            self.performLayoutUpdates(animated: false)
        }
    }
}

protocol RenameAccountScreenDelegate: AnyObject {
    func renameAccountScreenDidTapDoneButton(_ screen: RenameAccountScreen)
}
