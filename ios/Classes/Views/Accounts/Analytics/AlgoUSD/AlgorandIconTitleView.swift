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
//   AlgorandIconTitleView.swift

import UIKit

class AlgorandIconTitleView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private lazy var algorandIconImageView = UIImageView(image: img("icon-algorand-bg-green"))

    private lazy var algorandNameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withText("title-algorand".localized)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupAlgorandIconImageViewLayout()
        setupAlgorandNameLabelLayout()
    }
}

extension AlgorandIconTitleView {
    private func setupAlgorandIconImageViewLayout() {
        addSubview(algorandIconImageView)

        algorandIconImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.imageSize)
            make.leading.top.bottom.equalToSuperview()
        }
    }

    private func setupAlgorandNameLabelLayout() {
        addSubview(algorandNameLabel)

        algorandNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(algorandIconImageView.snp.trailing).offset(layout.current.horizontalInset)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(algorandIconImageView)
        }
    }
}

extension AlgorandIconTitleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 8.0
    }
}
