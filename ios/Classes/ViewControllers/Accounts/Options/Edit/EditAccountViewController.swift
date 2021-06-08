// Copyright 2019 Algorand, Inc.

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
import SnapKit

class EditAccountViewController: BaseViewController {
    
    private lazy var editAccountView = EditAccountView()
    
    private var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?
    fileprivate let account: Account
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            guard let name = strongSelf.editAccountView.accountNameTextField.text else {
                strongSelf.displaySimpleAlertWith(
                    title: "title-error".localized,
                    message: "account-name-setup-empty-error-message".localized
                )
                return
            }
            
            strongSelf.account.name = name
            strongSelf.session?.updateName(name, for: strongSelf.account.address)
            strongSelf.dismissScreen()
        }
        
        rightBarButtonItems = [doneBarButtonItem]
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        title = "options-edit-account-name".localized
        setSecondaryBackgroundColor()
        editAccountView.accountNameTextField.text = account.name
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupEditAccountViewLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editAccountView.accountNameTextField.becomeFirstResponder()
    }
    
    private var modalSize: ModalSize {
        let kbHeight = keyboard.height ?? 0.0
        let size = CGSize(
            width: self.view.bounds.width,
            height: kbHeight + 154.0
        )
        return .custom(size)
    }
}

extension EditAccountViewController {
    private func setupEditAccountViewLayout() {
        view.addSubview(editAccountView)
        
        editAccountView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(0.0).constraint
        }
    }
}

extension EditAccountViewController {
    @objc
    private func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? 0.0
        
        keyboard.height = kbHeight
        
        let inset = kbHeight - self.view.safeAreaInsets.bottom
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        self.contentViewBottomConstraint?.update(inset: inset)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.modalPresenter?.changeModalSize(to: self.modalSize, animated: false)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}
