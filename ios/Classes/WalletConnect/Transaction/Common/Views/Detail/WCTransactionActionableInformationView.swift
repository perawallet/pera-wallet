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
//   WCTransactionActionableInformationView.swift

import UIKit

class WCTransactionActionableInformationView: BaseControl {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel = TransactionDetailTitleLabel()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.right)
            .withTextColor(Colors.Text.link)
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

extension WCTransactionActionableInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelVerticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        detailLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.labelVerticalInset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.detailLabelOffset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorHorizontalInset)
        }
    }
}

extension WCTransactionActionableInformationView {
    func bind(_ viewModel: WCTransactionActionableInformationViewModel) {
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
        separatorView.isHidden = viewModel.isSeparatorHidden
    }
}

extension WCTransactionActionableInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let detailLabelOffset: CGFloat = 20.0
        let horizontalInset: CGFloat = 20.0
        let labelVerticalInset: CGFloat = 20.0
        let separatorHorizontalInset: CGFloat = 16.0
        let separatorHeight: CGFloat = 1.0
    }
}
