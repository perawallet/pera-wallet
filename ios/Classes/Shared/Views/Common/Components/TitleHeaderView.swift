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
//   TitleHeaderView.swift


import Foundation
import UIKit
import MacaroonUIKit

final class TitleHeaderView: View, ViewModelBindable, ListReusable {
    private lazy var titleLabel = UILabel()

    func customize(_ theme: TitleHeaderViewTheme) {
        addTitleLabel(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: SelectAccountHeaderViewModel?) {
        titleLabel.text = viewModel?.title
    }
}

extension TitleHeaderView {
    private func addTitleLabel(_ theme: TitleHeaderViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class TitleHeaderSupplementaryView: BaseSupplementaryView<TitleHeaderView> {
    override func configureAppearance() {
        contextView.customize(TitleHeaderViewTheme())
    }

    func bind(_ viewModel: SelectAccountHeaderViewModel) {
        contextView.bindData(viewModel)
    }
}

final class TitleHeaderCell:
    CollectionCell<TitleHeaderView>,
    ViewModelBindable {
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contextView.customize(TitleHeaderViewTheme())
    }
}
