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
//   LedgerAccountVerificationStatusView.swift

import UIKit

class LedgerAccountVerificationStatusView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var backgroundView = UIView()

    private lazy var verificationStatusView = VerificationStatusView()

    private lazy var addressLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.left)
    }()

    override func configureAppearance() {
        backgroundView.layer.cornerRadius = 12.0
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupBackgroundViewLayout()
        setupVerificationStatusViewLayout()
        setupAddressLabelLayout()
    }
}

extension LedgerAccountVerificationStatusView {
    private func setupBackgroundViewLayout() {
        addSubview(backgroundView)

        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }

    private func setupVerificationStatusViewLayout() {
        backgroundView.addSubview(verificationStatusView)

        verificationStatusView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupAddressLabelLayout() {
        backgroundView.addSubview(addressLabel)

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(verificationStatusView.snp.bottom).offset(layout.current.addressLabelTopInset)
            make.leading.equalToSuperview().inset(layout.current.addressLabelLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension LedgerAccountVerificationStatusView {
    func showLoading() {
        verificationStatusView.showLoading()
    }

    func stopLoading() {
        verificationStatusView.stopLoading()
    }
}

extension LedgerAccountVerificationStatusView {
    func bind(_ viewModel: LedgerAccountVerificationStatusViewModel) {
        addressLabel.text = viewModel.address
        backgroundView.backgroundColor = viewModel.backgroundColor
        backgroundView.layer.borderColor = viewModel.borderColor?.cgColor

        if let verificationStatusViewModel = viewModel.verificationStatusViewModel {
            verificationStatusView.bind(verificationStatusViewModel)
        }
    }
}

extension LedgerAccountVerificationStatusView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let addressLabelLeadingInset: CGFloat = 60.0
        let addressLabelTopInset: CGFloat = 4.0
        let topInset: CGFloat = 16.0
        let bottomInset: CGFloat = 20.0
    }
}
