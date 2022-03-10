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

final class SelectContactView: View {
    private(set) lazy var userImageView = UIImageView()
    private lazy var nameLabel = UILabel()

    func customize(_ theme: SelectContactViewTheme) {
        addUserImageView(theme)
        addNameLabel(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

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

extension SelectContactView: ViewModelBindable {
    func bindData(_ viewModel: ContactsViewModel?) {
        userImageView.image = viewModel?.image
        nameLabel.text = viewModel?.name
    }
}

final class SelectContactCell: BaseCollectionViewCell<SelectContactView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(SelectContactViewTheme())
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.userImageView.image = img("icon-user-placeholder")
    }

    func bindData(_ viewModel: ContactsViewModel) {
        contextView.bindData(viewModel)
    }

    func customize(_ theme: SelectContactViewTheme) {
        contextView.customize(theme)
    }
}
