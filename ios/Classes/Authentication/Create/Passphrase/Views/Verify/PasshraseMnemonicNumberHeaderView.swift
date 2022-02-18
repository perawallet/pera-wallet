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
//  PasshraseMnemonicNumberHeaderView.swift

import UIKit

class PasshraseMnemonicNumberHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.secondary)
            .withAlignment(.left)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
    }
}

extension PasshraseMnemonicNumberHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview()
        }
    }
}

extension PasshraseMnemonicNumberHeaderView {
    func bind(_ viewModel: PasshraseMnemonicNumberHeaderViewModel) {
        titleLabel.text = viewModel.number
    }
}

extension PasshraseMnemonicNumberHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
    }
}
