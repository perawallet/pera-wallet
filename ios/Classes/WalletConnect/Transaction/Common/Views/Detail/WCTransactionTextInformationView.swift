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
//   WCTransactionTextInformationView.swift

import UIKit

class WCTransactionTextInformationView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel = TransactionDetailTitleLabel()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    private lazy var separatorView = LineSeparatorView()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension WCTransactionTextInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
        }
    }

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumOffset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
}

extension WCTransactionTextInformationView {
    func bind(_ viewModel: WCTransactionTextInformationViewModel) {
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
        separatorView.isHidden = viewModel.isSeparatorHidden
    }
}

extension WCTransactionTextInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let minimumOffset: CGFloat = 8.0
        let separatorHeight: CGFloat = 1.0
    }
}
