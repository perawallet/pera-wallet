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
//  TransactionContactInformationView.swift

import UIKit
import MacaroonUIKit

final class TransactionContactInformationView: View {
    weak var delegate: TransactionContactInformationViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var contactDisplayView = ContactDisplayView()
    
    func linkInteractors() {
        contactDisplayView.delegate = self
        contactDisplayView.setListeners()
    }

    func customize(_ theme: TransactionContactInformationViewTheme) {
        addTitleLabel(theme)
        addContactDisplayView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension TransactionContactInformationView {
    private func addTitleLabel(_ theme: TransactionContactInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }

    private func addContactDisplayView(_ theme: TransactionContactInformationViewTheme) {
        contactDisplayView.customize(theme.contactDisplayViewTheme)

        addSubview(contactDisplayView)
        contactDisplayView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.contactDisplayLeadingPadding)
        }
    }
}

extension TransactionContactInformationView: ViewModelBindable {
    func bindData(_ viewModel: TransactionContactInformationViewModel?) {
        if let title = viewModel?.title {
            titleLabel.text = title
        }

        if let contactDisplayViewModel = viewModel?.contactDisplayViewModel {
            contactDisplayView.bindData(contactDisplayViewModel)
        }
    }
}

extension TransactionContactInformationView: ContactDisplayViewDelegate {
    func contactDisplayViewDidTapAddContactButton(_ contactDisplayView: ContactDisplayView) {
        delegate?.transactionContactInformationViewDidTapAddContactButton(self)
    }
}

protocol TransactionContactInformationViewDelegate: AnyObject {
    func transactionContactInformationViewDidTapAddContactButton(_ transactionContactInformationView: TransactionContactInformationView)
}
