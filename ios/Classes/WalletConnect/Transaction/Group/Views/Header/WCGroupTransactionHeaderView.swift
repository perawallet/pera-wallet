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
//   WCGroupTransactionHeaderView.swift

import UIKit

final class WCGroupTransactionHeaderView: BaseView {
    private let layout = Layout<LayoutConstants>()

    private lazy var groupIDLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.gray.uiColor)
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(Fonts.DMMono.regular.make(15).uiFont)
    }()

    override func prepareLayout() {
        setupGroupIDLabelLayout()
    }

    override func configureAppearance() {
        super.configureAppearance()
        backgroundColor = Colors.Defaults.background.uiColor
    }
}

extension WCGroupTransactionHeaderView {
    private func setupGroupIDLabelLayout() {
        addSubview(groupIDLabel)

        groupIDLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension WCGroupTransactionHeaderView {
    func bind(_ viewModel: WCGroupTransactionHeaderViewModel) {
        groupIDLabel.text = viewModel.groupID
    }
}

extension WCGroupTransactionHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 28.0
        let bottomInset: CGFloat = 8
    }
}
