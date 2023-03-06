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
//   SelectContactView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SelectContactView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var userImageView = UIImageView()
    private lazy var nameLabel = Label()

    func customize(_ theme: SelectContactViewTheme) {
        addUserImageView(theme)
        addNameLabel(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: ContactsViewModel?) {
        userImageView.image = viewModel?.image
        nameLabel.editText = viewModel?.name
    }

    class func calculatePreferredSize(
        _ viewModel: ContactsViewModel?,
        for theme: SelectContactViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = theme.imageSize
        let titleSize = viewModel.name.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )

        let preferredHeight = max(iconSize.h, titleSize.height)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        userImageView.image = "icon-user-placeholder".uiImage
    }
}

extension SelectContactView {
    private func addUserImageView(_ theme: SelectContactViewTheme) {
        userImageView.customizeAppearance(theme.userImage)
        userImageView.layer.cornerRadius = theme.userImageCorner.radius
        userImageView.clipsToBounds = true

        addSubview(userImageView)
        userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
        }
    }

    private func addNameLabel(_ theme: SelectContactViewTheme) {
        nameLabel.customizeAppearance(theme.nameLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(userImageView.snp.trailing).offset(theme.nameLabelLeadingInset)
            $0.trailing.equalToSuperview()
        }
    }
}

final class SelectContactCell:
    CollectionCell<SelectContactView>,
    ViewModelBindable {
    override class var contextPaddings: LayoutPaddings {
        return (14, 0, 14, 0)
    }

    static let theme = SelectContactViewTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customize(Self.theme)
    }
}
