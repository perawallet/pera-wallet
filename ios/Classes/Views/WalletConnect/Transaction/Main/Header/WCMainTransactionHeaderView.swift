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
//   WCMainTransactionHeaderView.swift

import UIKit

class WCMainTransactionHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCMainTransactionHeaderViewDelegate?

    private lazy var stackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = layout.current.spacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    override func prepareLayout() {
        setupStackViewLayout()
    }

    override func linkInteractors() {
        dappMessageView.delegate = self
    }
}

extension WCMainTransactionHeaderView {
    private func setupStackViewLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }

        stackView.addArrangedSubview(dappMessageView)
        stackView.addArrangedSubview(titleLabel)
    }
}

extension WCMainTransactionHeaderView: WCTransactionDappMessageViewDelegate {
    func wcTransactionDappMessageViewDidTapped(_ WCTransactionDappMessageView: WCTransactionDappMessageView) {
        delegate?.wcMainTransactionHeaderViewDidOpenLongMessageView(self)
    }
}

extension WCMainTransactionHeaderView {
    func bind(_ viewModel: WCMainTransactionHeaderViewModel) {
        if let transactionDappMessageViewModel = viewModel.transactionDappMessageViewModel {
            dappMessageView.bind(transactionDappMessageViewModel)
        }

        titleLabel.text = viewModel.title
    }
}

extension WCMainTransactionHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 20.0
        let spacing: CGFloat = 28.0
    }
}

protocol WCMainTransactionHeaderViewDelegate: AnyObject {
    func wcMainTransactionHeaderViewDidOpenLongMessageView(_ wcMainTransactionHeaderView: WCMainTransactionHeaderView)
}
