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
//   WCConnectionAccountSelectionView.swift

import UIKit
import MacaroonUIKit
import SnapKit

final class WCConnectionAccountSelectionView:
    Control,
    ViewModelBindable {
    private lazy var contentView = TripleShadowView()
    private lazy var typeImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var arrowImageView = UIImageView()

    struct Configuration {
        var showsArrowImageView = false
    }

    private let configuration: Configuration
    private let theme: WCConnectionAccountSelectionViewTheme

    init(
        theme: WCConnectionAccountSelectionViewTheme,
        configurationHandler: (inout Configuration) -> Void = { _ in }
    ) {
        self.theme = theme
        var configuration = Configuration()
        configurationHandler(&configuration)
        self.configuration = configuration

        super.init(frame: .zero)
        
        customize(theme)
    }

    func customize(_ theme: WCConnectionAccountSelectionViewTheme) {
        addContent()
        addTypeImageView(theme)

        if configuration.showsArrowImageView {
            addArrowImageView(theme)
        }

        addNameLabel(theme)
        addDetailLabel(theme)
    }

    func bindData(
        _ viewModel: WCConnectionAccountSelectionViewModel?
    ) {
        typeImageView.image = viewModel?.icon
        nameLabel.text = viewModel?.title
        detailLabel.text = viewModel?.subtitle
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension WCConnectionAccountSelectionView {
    private func addContent() {
        contentView.isUserInteractionEnabled = false

        contentView.drawAppearance(shadow: theme.firstShadow)
        contentView.drawAppearance(secondShadow: theme.secondShadow)
        contentView.drawAppearance(thirdShadow: theme.thirdShadow)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges == 0
        }
    }

    private func addTypeImageView(_ theme: WCConnectionAccountSelectionViewTheme) {
        typeImageView.customizeAppearance(theme.iconImage)

        contentView.addSubview(typeImageView)
        typeImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.iconVerticalInset)
        }
    }

    private func addArrowImageView(_ theme: WCConnectionAccountSelectionViewTheme) {
        arrowImageView.customizeAppearance(theme.arrowImage)

        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.arrowIconSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addNameLabel(_ theme: WCConnectionAccountSelectionViewTheme) {
        nameLabel.customizeAppearance(theme.title)

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(typeImageView.snp.trailing).offset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.centerY.equalTo(typeImageView).priority(.low)
            makeTrailingConstraint($0, offset: -theme.horizontalInset)
        }
    }

    private func addDetailLabel(_ theme: WCConnectionAccountSelectionViewTheme) {
        detailLabel.customizeAppearance(theme.secondaryTitle)

        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
            makeTrailingConstraint($0, offset: -theme.horizontalInset)
        }
    }
}

extension WCConnectionAccountSelectionView {
    func makeTrailingConstraint(_ constraintMaker: ConstraintMaker, offset: LayoutMetric) {
        if configuration.showsArrowImageView {
            constraintMaker.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(offset)
        } else {
            constraintMaker.trailing.lessThanOrEqualToSuperview().offset(offset)
        }
    }
}
