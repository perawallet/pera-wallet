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
//   WCConnectionAccountSelectionView.swift

import UIKit

class WCConnectionAccountSelectionView: BaseControl {

    private let layout = Layout<LayoutConstants>()

    private lazy var typeImageView = UIImageView()

    private lazy var nameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.secondary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray-24"))

    override func configureAppearance() {
        backgroundColor = .clear
        layer.cornerRadius = 12.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.Component.dappImageBorderColor.cgColor
    }

    override func prepareLayout() {
        setupTypeImageViewLayout()
        setupArrowImageViewLayout()
        setupNameLabelLayout()
        setupDetailLabelLayout()
    }
}

extension WCConnectionAccountSelectionView {
    private func setupTypeImageViewLayout() {
        addSubview(typeImageView)

        typeImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.iconSize)
            make.leading.equalToSuperview().inset(layout.current.iconHorizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.iconVerticalInset)
        }
    }

    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.iconSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }

    private func setupNameLabelLayout() {
        addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(typeImageView.snp.trailing).offset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-layout.current.horizontalInset)
        }
    }

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-layout.current.horizontalInset)
        }
    }
}

extension WCConnectionAccountSelectionView {
    func bind(_ viewModel: WCConnectionAccountSelectionViewModel) {
        typeImageView.image = viewModel.image
        nameLabel.text = viewModel.accountName
        detailLabel.text = viewModel.detail
    }
}

extension WCConnectionAccountSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let verticalInset: CGFloat = 16.0
        let iconHorizontalInset: CGFloat = 20.0
        let iconVerticalInset: CGFloat = 26.0
        let horizontalInset: CGFloat = 16.0
    }
}
