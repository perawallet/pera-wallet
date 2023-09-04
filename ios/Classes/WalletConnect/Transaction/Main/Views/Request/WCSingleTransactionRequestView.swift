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
//   WCSingleTransactionRequestView.swift

import Foundation
import MacaroonBottomOverlay
import MacaroonUIKit
import UIKit

final class WCSingleTransactionRequestView: BaseView {
    private lazy var confirmButton = MacaroonUIKit.Button()
    private lazy var cancelButton = MacaroonUIKit.Button()
    private(set) lazy var bottomView = WCSingleTransactionRequestBottomView()
    private(set) lazy var middleView = WCSingleTransactionRequestMiddleView()

    private lazy var theme = WCSingleTransactionRequestViewTheme()

    weak var delegate: WCSingleTransactionRequestViewDelegate?

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = theme.backgroundColor.uiColor
        bottomView.backgroundColor = theme.backgroundColor.uiColor
        middleView.backgroundColor = theme.backgroundColor.uiColor

        middleView.startObserving(event: .didOpenASADiscovery) {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.wcSingleTransactionRequestViewDidOpenASADiscovery(self)
        }
    }

    override func linkInteractors() {
        super.linkInteractors()

        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        bottomView.showTransactionDetailsButton.addTarget(self, action: #selector(didTapShowTransaction), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addButtons()
        addBottomView()
        addMiddleView()
    }

    func bind(_ viewModel: WCSingleTransactionRequestViewModel?) {
        bottomView.bind(viewModel?.bottomView)
        middleView.bind(viewModel?.middleView)
    }
}

extension WCSingleTransactionRequestView {
    @objc
    private func didTapCancel() {
        delegate?.wcSingleTransactionRequestViewDidTapCancel(self)
    }

    @objc
    private func didTapConfirm() {
        delegate?.wcSingleTransactionRequestViewDidTapConfirm(self)
    }

    @objc
    private func didTapShowTransaction() {
        delegate?.wcSingleTransactionRequestViewDidTapShowTransaction(self)
    }
}

extension WCSingleTransactionRequestView {
    private func addButtons() {
        cancelButton.customizeAppearance(theme.cancelButton)
        addSubview(cancelButton)
        cancelButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)
        cancelButton.snp.makeConstraints { make in
            let safeAreaBottom = compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.buttonHorizontalPadding
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalToSuperview().inset(theme.horizontalPadding)
        }

        confirmButton.customizeAppearance(theme.confirmButton)
        addSubview(confirmButton)
        confirmButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)
        confirmButton.snp.makeConstraints { make in
            let safeAreaBottom = compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.buttonHorizontalPadding
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalTo(cancelButton.snp.trailing).offset(theme.buttonHorizontalPadding)
            make.trailing.equalToSuperview().inset(theme.horizontalPadding)
            make.height.equalTo(cancelButton)
            make.width.equalTo(cancelButton).multipliedBy(theme.confirmButtonWidthMultiplier)
        }
    }

    private func addBottomView() {
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(theme.bottomViewBottomOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(theme.bottomHeight)
        }
    }

    private func addMiddleView() {
        addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            make.bottom.equalTo(bottomView.snp.top)
        }

        middleView.addSeparator(theme.separator)
    }
}

protocol WCSingleTransactionRequestViewDelegate: AnyObject {
    func wcSingleTransactionRequestViewDidTapCancel(
        _ requestView: WCSingleTransactionRequestView
    )
    func wcSingleTransactionRequestViewDidTapConfirm(
        _ requestView: WCSingleTransactionRequestView
    )
    func wcSingleTransactionRequestViewDidTapShowTransaction(
        _ requestView: WCSingleTransactionRequestView
    )
    func wcSingleTransactionRequestViewDidOpenASADiscovery(
        _ requestView: WCSingleTransactionRequestView
    )
}
