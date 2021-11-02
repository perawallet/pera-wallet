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
//   WCGroupTransactionHeaderView.swift

import UIKit

class WCGroupTransactionHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Background.secondary
        view.layer.cornerRadius = 12.0
        return view
    }()

    private lazy var idTitleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("wallet-connect-transaction-group-id".localized)
    }()

    private lazy var groupIDLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    override func prepareLayout() {
        setupContainerViewLayout()
        setupIDTitleLabelLayout()
        setupGroupIDLabelLayout()
        setupTitleLabelLayout()
    }
}

extension WCGroupTransactionHeaderView {
    private func setupContainerViewLayout() {
        addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupIDTitleLabelLayout() {
        containerView.addSubview(idTitleLabel)

        idTitleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupGroupIDLabelLayout() {
        containerView.addSubview(groupIDLabel)

        groupIDLabel.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.titleTopInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension WCGroupTransactionHeaderView {
    func bind(_ viewModel: WCGroupTransactionHeaderViewModel) {
        titleLabel.text = viewModel.title
        groupIDLabel.text = viewModel.groupID
    }
}

extension WCGroupTransactionHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 28.0
    }
}
