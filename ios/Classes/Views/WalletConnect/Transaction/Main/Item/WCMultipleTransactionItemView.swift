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
//   WCMultipleTransactionItemView.swift

import UIKit

class WCMultipleTransactionItemView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleStackView: HStackView = {
        let stackView = HStackView()
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8.0
        stackView.alignment = .center
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var warningImageView = UIImageView(image: img("icon-orange-warning"))

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withText("wallet-connect-transaction-title-multiple".localized)
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray-24"))

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
    }

    override func prepareLayout() {
        setupArrowImageViewLayout()
        setupTitleStackViewLayout()
        setupDetailLabelLayout()
    }
}

extension WCMultipleTransactionItemView {
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.arrowImageSize)
        }
    }

    private func setupTitleStackViewLayout() {
        addSubview(titleStackView)

        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.stackTrailingOffset)
        }

        titleStackView.addArrangedSubview(warningImageView)
        titleStackView.addArrangedSubview(titleLabel)
    }

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-layout.current.minimumOffset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension WCMultipleTransactionItemView {
    func bind(_ viewModel: WCMultipleTransactionItemViewModel) {
        warningImageView.isHidden = !viewModel.hasWarning
        detailLabel.text = viewModel.detail
    }
}

extension WCMultipleTransactionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 24.0
        let arrowImageSize = CGSize(width: 24.0, height: 24.0)
        let stackTrailingOffset: CGFloat = 44.0
        let minimumOffset: CGFloat = 4.0
        let detailTopInset: CGFloat = 8.0
    }
}
