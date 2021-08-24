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
//   TitledTransactionAmountInformationView.swift

import UIKit

class TitledTransactionAmountInformationView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel = TransactionDetailTitleLabel()

    private lazy var transactionAmountView = TransactionAmountView()

    private lazy var separatorView = LineSeparatorView()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTransactionAmountViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TitledTransactionAmountInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)

        transactionAmountView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.transactionAmountViewOffset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.transactionAmountViewOffset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension TitledTransactionAmountInformationView {
    func bind(_ viewModel: TitledTransactionAmountInformationViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.text = viewModel.title

        if let amountMode = viewModel.amountMode {
            transactionAmountView.mode = amountMode
        }

        separatorView.isHidden = viewModel.isSeparatorHidden
    }
}

extension TitledTransactionAmountInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let transactionAmountViewOffset: CGFloat = 18.0
        let labelTopInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
}
