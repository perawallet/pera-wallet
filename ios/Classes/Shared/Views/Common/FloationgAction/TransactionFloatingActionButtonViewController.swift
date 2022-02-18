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
//   TransactionFloatingActionButtonViewController.swift

import MacaroonUIKit
import UIKit
import SnapKit

final class TransactionFloatingActionButtonViewController: BaseViewController {
    weak var delegate: TransactionFloatingActionButtonViewControllerDelegate?

    private lazy var chromeView = UIControl()
    private lazy var closeButton = FloatingActionItemButton()
    private lazy var receiveButton = FloatingActionItemButton()
    private lazy var sendButton = FloatingActionItemButton()
    private lazy var theme = Theme()

    override func setListeners() {
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(didTapReceiveButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapChromeView), for: .touchUpInside)
        chromeView.addTarget(self, action: #selector(didTapChromeView), for: .touchUpInside)
    }

    override func prepareLayout() {
        addChrome(theme)
        addCloseButton(theme)
        addReceiveButton(theme)
        addSendButton(theme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateView()
    }
}

extension TransactionFloatingActionButtonViewController {
    private func addChrome(_ theme: Theme) {
        chromeView.customizeAppearance(theme.chromeStyle)
        chromeView.alpha = .zero

        view.addSubview(chromeView)
        chromeView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addCloseButton(_ theme: Theme) {
        closeButton.image = "fab-close".uiImage
        closeButton.title = "title-close".localized

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.trailingPadding)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding + view.safeAreaBottom)
        }
    }

    private func addReceiveButton(_ theme: Theme) {
        receiveButton.image = "fab-receive".uiImage
        receiveButton.title = "title-receive".localized

        view.addSubview(receiveButton)
        receiveButton.snp.makeConstraints {
            $0.trailing.equalTo(closeButton)
            $0.bottom.equalTo(closeButton.snp.top)
        }

        receiveButton.alpha = .zero
    }

    private func addSendButton(_ theme: Theme) {
        sendButton.image = "fab-send".uiImage
        sendButton.title = "title-send".localized
        
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.trailing.equalTo(closeButton)
            $0.bottom.equalTo(receiveButton.snp.top).inset(-theme.buttonVerticalSpacing)
        }

        sendButton.alpha = .zero
    }
}

extension TransactionFloatingActionButtonViewController {
    @objc
    private func didTapChromeView() {
        dismissWithAnimation()
    }
}

extension TransactionFloatingActionButtonViewController {
    private func animateView() {
        animateChromeView()
        showButtonsWithAnimation()
    }

    private func animateChromeView() {
        updateChromeViewVisibility(to: 1)
    }

    private func showButtonsWithAnimation() {
        receiveButton.snp.updateConstraints {
            $0.bottom.equalTo(closeButton.snp.top).offset(-theme.buttonVerticalSpacing)
        }

        var delay = 0.0
        let animationSpeed = 0.05

        [receiveButton, sendButton].forEach { button in
            UIView.animate(withDuration: 0.2,
                           delay: delay,
                           animations: {
                button.alpha = 1
            })

            delay += animationSpeed * 2
        }
    }

    private func dismissWithAnimation() {
        updateChromeViewVisibility(to: .zero) {
            self.dismiss(animated: false)
        }
        hideButtonsWithAnimation()
    }

    private func updateChromeViewVisibility(to alpha: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) {
            self.chromeView.alpha = alpha
        } completion: { _ in
           completion?()
        }
    }

    private func hideButtonsWithAnimation() {
        [sendButton, receiveButton, closeButton].forEach { button in
            UIView.animate(withDuration: 0.2) {
                button.alpha = 0
            }
        }
    }
}

extension TransactionFloatingActionButtonViewController {
    @objc
    private func didTapSendButton() {
        delegate?.transactionFloatingActionButtonViewControllerDidSend(self)
        dismissScreen(animated: false)
    }

    @objc
    private func didTapReceiveButton() {
        delegate?.transactionFloatingActionButtonViewControllerDidReceive(self)
        dismissScreen(animated: false)
    }
}

protocol TransactionFloatingActionButtonViewControllerDelegate: AnyObject {
    func transactionFloatingActionButtonViewControllerDidSend(_ viewController: TransactionFloatingActionButtonViewController)
    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController)
}
