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
//   WCAssetConfigTransactionItemView.swift

import UIKit

class WCAssetConfigTransactionItemView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var senderStackView: HStackView = {
        let stackView = HStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .leading
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var warningImageView = UIImageView(image: img("icon-orange-warning"))

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()

    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray-24"))

    private(set) lazy var accountInformationView = WCGroupTransactionAccountInformationView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
    }

    override func prepareLayout() {
        setupSenderStackViewLayout()
        setupArrowImageViewLayout()
        setupDetailLabelLayout()
        setupAccountInformationViewLayout()
    }
}

extension WCAssetConfigTransactionItemView {
    private func setupSenderStackViewLayout() {
        addSubview(senderStackView)

        senderStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().offset(layout.current.stackTrailingOffset)
        }

        senderStackView.addArrangedSubview(warningImageView)
        senderStackView.addArrangedSubview(titleLabel)
    }

    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(senderStackView)
            make.size.equalTo(layout.current.arrowImageSize)
        }
    }

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(senderStackView.snp.bottom).offset(layout.current.detailTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupAccountInformationViewLayout() {
        addSubview(accountInformationView)

        accountInformationView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.accountInformationViewTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.accountInformationViewInset)
            make.height.greaterThanOrEqualTo(layout.current.accountInformationHeight)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.accountInformationViewInset)
        }
    }
}

extension WCAssetConfigTransactionItemView {
    func bind(_ viewModel: WCAssetConfigTransactionItemViewModel) {
        warningImageView.isHidden = !viewModel.hasWarning
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail

        if let accountInformationViewModel = viewModel.accountInformationViewModel {
            accountInformationView.bind(accountInformationViewModel)
        }
    }
}

extension WCAssetConfigTransactionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 24.0
        let horizontalInset: CGFloat = 20.0
        let arrowImageSize = CGSize(width: 24.0, height: 24.0)
        let stackTrailingOffset: CGFloat = 44.0
        let senderStackHeight: CGFloat = 20.0
        let detailTopInset: CGFloat = 8.0
        let accountInformationHeight: CGFloat = 36.0
        let accountInformationViewTopInset: CGFloat = 12.0
        let accountInformationViewInset: CGFloat = 8.0
    }
}
