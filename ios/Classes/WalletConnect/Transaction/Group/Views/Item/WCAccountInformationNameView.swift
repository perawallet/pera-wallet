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
//   WCAccountInformationNameView.swift

import UIKit

final class WCAccountInformationNameView: BaseView {
    private let layout = Layout<LayoutConstants>()

    private lazy var imageView = UIImageView()

    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.gray.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.regular.make(13).uiFont)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupImageViewLayout()
        setupNameLabelLayout()
    }
}

extension WCAccountInformationNameView {
    private func setupImageViewLayout() {
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview()
        }
    }

    private func setupNameLabelLayout() {
        addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension WCAccountInformationNameView {
    func bind(_ viewModel: AccountNameViewModel) {
        imageView.load(from: viewModel.image)
        nameLabel.text = viewModel.name
    }
}

extension WCAccountInformationNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 8.0
        let imageSize = CGSize(width: 16.0, height: 16.0)
    }
}
