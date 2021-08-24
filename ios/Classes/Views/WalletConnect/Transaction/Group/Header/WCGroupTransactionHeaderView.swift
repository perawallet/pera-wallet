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

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    override func prepareLayout() {
        setupTitleLabelLayout()
    }
}

extension WCGroupTransactionHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLeadingInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension WCGroupTransactionHeaderView {
    func bind(_ viewModel: WCGroupTransactionHeaderViewModel) {
        titleLabel.text = viewModel.title
    }
}

extension WCGroupTransactionHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let titleLeadingInset: CGFloat = 24.0
    }
}
