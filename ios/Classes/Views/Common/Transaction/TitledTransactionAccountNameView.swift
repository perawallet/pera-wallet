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
//   TitledTransactionAccountNameView.swift

import UIKit

class TitledTransactionAccountNameView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel = TransactionDetailTitleLabel()

    private lazy var accountNameView = AccountNameView()

    private lazy var separatorView = LineSeparatorView()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TitledTransactionAccountNameView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
        }
    }

    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)

        accountNameView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumOffset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension TitledTransactionAccountNameView {
    func bind(_ viewModel: TitledTransactionAccountNameViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.text = viewModel.title
        
        if let accountNameViewModel = viewModel.accountNameViewModel {
            accountNameView.bind(accountNameViewModel)
        }

        separatorView.isHidden = viewModel.isSeparatorHidden
    }
}

extension TitledTransactionAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 22.0
        let verticalInset: CGFloat = 18.0
        let minimumOffset: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
    }
}
