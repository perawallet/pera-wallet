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
//  LedgerApprovalView.swift

import UIKit
import MacaroonUIKit

final class LedgerApprovalView: View {
    weak var delegate: LedgerApprovalViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var imageView = LottieImageView()
    private lazy var descriptionLabel = UILabel()
    private lazy var cancelButton = Button()

    func customize(_ theme: LedgerApprovalViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addCancelButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancel), for: .touchUpInside)
    }
}

extension LedgerApprovalView {
    @objc
    private func notifyDelegateToCancel() {
        delegate?.ledgerApprovalViewDidTapCancelButton(self)
    }
}

extension LedgerApprovalView {
    private func addImageView(_ theme: LedgerApprovalViewTheme) {
        imageView.setAnimation(theme.lottie)
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTitleLabel(_ theme: LedgerApprovalViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(_ theme: LedgerApprovalViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addCancelButton(_ theme: LedgerApprovalViewTheme) {
        cancelButton.customize(theme.cancelButtonTheme)
        cancelButton.bindData(ButtonCommonViewModel(title: "ledger-approval-cancel-title".localized))

        addSubview(cancelButton)
        cancelButton.fitToVerticalIntrinsicSize()
        cancelButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(theme.verticalInset)
        }
    }
}

extension LedgerApprovalView: ViewModelBindable {
    func bindData(_ viewModel: LedgerApprovalViewModel?) {
        titleLabel.text = viewModel?.title
        descriptionLabel.text = viewModel?.description
    }
}

extension LedgerApprovalView {
    func startConnectionAnimation() {
        imageView.play(with: LottieImageView.Configuration())
    }

    func stopConnectionAnimation() {
        imageView.stop()
    }
}

protocol LedgerApprovalViewDelegate: AnyObject {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView)
}
