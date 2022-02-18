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
//   SingleLineIconTitleView.swift

import UIKit
import MacaroonUIKit

final class SingleLineIconTitleView:
    View,
    ListReusable {
    private lazy var iconView = UIImageView()
    private lazy var titleLabel = UILabel()

    func customize(_ theme: SingleLineIconTitleViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addIconView(theme)
        addTitleLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension SingleLineIconTitleView {
    private func addIconView(_ theme: SingleLineIconTitleViewTheme) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.equalToSuperview()
            $0.size.equalTo(CGSize(theme.iconSize))
        }
    }

    private func addTitleLabel(_ theme: SingleLineIconTitleViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.equalTo(iconView.snp.trailing).offset(theme.titleHorizontalPadding)
            $0.trailing.equalToSuperview().inset(theme.titleHorizontalPadding)
        }
    }
}

extension SingleLineIconTitleView: ViewModelBindable {
    func bindData(_ viewModel: SingleLineIconTitleViewModel?) {
        iconView.image = viewModel?.icon?.uiImage
        titleLabel.editText = viewModel?.title
    }
}

final class SingleLineIconTitleCell:
    TableCell<SingleLineIconTitleView>,
    ViewModelBindable,
    ListIdentifiable {
    override class var contextPaddings: LayoutPaddings {
        return (0, 24, 0, 24)
    }

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        
        contextView.customize(SingleLineIconTitleViewTheme())

        backgroundColor = .clear
        selectionStyle = .none
    }
}
