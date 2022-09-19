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
//   JSONDisplayView.swift

import UIKit

class JSONDisplayView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var jsonLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(Colors.Text.main.uiColor)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Defaults.background.uiColor
    }

    override func prepareLayout() {
        setupJSONLabelLayout()
    }
}

extension JSONDisplayView {
    private func setupJSONLabelLayout() {
        addSubview(jsonLabel)

        jsonLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension JSONDisplayView {
    func bind(_ viewModel: JSONDisplayViewModel) {
        jsonLabel.text = viewModel.jsonText
    }
}

extension JSONDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 32.0
    }
}
