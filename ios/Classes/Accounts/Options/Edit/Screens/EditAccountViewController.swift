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
//  EditAccountViewController.swift

import UIKit

// <todo>: Handle keyboard 
final class EditAccountViewController: BaseViewController {
    weak var delegate: EditAccountViewControllerDelegate?

    private lazy var theme = Theme()
    private lazy var editAccountView = EditAccountView()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "options-edit-account-name".localized
    }
    
    override func setListeners() {
        editAccountView.delegate = self
    }
    
    override func prepareLayout() {
        editAccountView.customize(theme.editAccountViewTheme)
        view.addSubview(editAccountView)
        editAccountView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        editAccountView.bindData(account.name)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editAccountView.beginEditing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        editAccountView.endEditing()
    }
}

extension EditAccountViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Text.main.uiColor)) {
            [weak self] in

            guard let self = self else {
                return
            }

            self.didTapDoneButton()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }

    private func didTapDoneButton() {
        let accountName: String
        if let name = editAccountView.accountNameInputView.text,
           !name.isEmpty {
            accountName = name
        } else {
            accountName = account.address.shortAddressDisplay
        }

        /// <note>
        /// Since the syncing is always running, the references of the cached accounts may change
        /// at this moment. Let's be sure we can switch to the new name immediately.
        let cachedAccount = sharedDataController.accountCollection[account.address]?.value
        cachedAccount?.name = accountName

        account.name = accountName
        session?.updateName(accountName, for: account.address)

        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.editAccountViewControllerDidTapDoneButton(self)
        }
    }
}

extension EditAccountViewController: EditAccountViewDelegate {
    func editAccountViewDidTapDoneButton(_ editAccountView: EditAccountView) {
        didTapDoneButton()
    }
}

protocol EditAccountViewControllerDelegate: AnyObject {
    func editAccountViewControllerDidTapDoneButton(_ viewController: EditAccountViewController)
}
