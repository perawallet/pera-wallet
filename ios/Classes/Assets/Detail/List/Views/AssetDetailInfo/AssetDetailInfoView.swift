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
//   AssetDetailInfoView.swift

import MacaroonUIKit
import UIKit

final class AssetDetailInfoView:
    View,
    ViewModelBindable,
    ListReusable {
    weak var delegate: AssetDetailInfoViewDelegate?

    private lazy var yourBalanceTitleLabel = UILabel()
    private lazy var balanceLabel = UILabel()
    private lazy var secondaryValueLabel = Label()
    private lazy var topSeparator = UIView()
    private lazy var assetNameView = UIView()
    private lazy var assetNameLabel = UILabel()
    private lazy var assetIDButton = Button(.imageAtRight(spacing: 8))
    private lazy var verifiedImage = UIImageView()
    private lazy var bottomSeparator = UIView()

    func setListeners() {
        assetIDButton.addTarget(self, action: #selector(notifyDelegateToCopyAssetID), for: .touchUpInside)
    }

    func customize(
        _ theme: AssetDetailInfoViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addYourBalanceTitleLabel(theme)
        addBalanceLabel(theme)
        addSecondaryValueLabel(theme)
        addTopSeparator(theme)
        addAssetNameLabel(theme)
        addAssetIDButton(theme)
        addBottomSeparator(theme)
    }

    func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func bindData(
        _ viewModel: AssetDetailInfoViewModel?
    ) {
        yourBalanceTitleLabel.editText = viewModel?.yourBalanceTitle
        verifiedImage.isHidden = !(viewModel?.isVerified ?? false)
        balanceLabel.editText = viewModel?.amount
        secondaryValueLabel.editText = viewModel?.secondaryValue
        assetNameLabel.editText = viewModel?.name
        assetIDButton.setEditTitle(viewModel?.ID, for: .normal)
    }

    class func calculatePreferredSize(
        _ viewModel: AssetDetailInfoViewModel?,
        for theme: AssetDetailInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width =
            size.width -
            2 * theme.horizontalPadding
        let yourBalanceTitleSize = viewModel.yourBalanceTitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let amountSize = viewModel.amount.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let nameSize = viewModel.name.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let assetIDButtonSize = viewModel.ID.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        var preferredHeight =
        theme.topPadding +
        yourBalanceTitleSize.height +
        theme.balanceLabelTopPadding +
        amountSize.height +
        theme.separatorPadding +
        theme.separator.size +
        theme.assetNameLabelTopPadding +
        nameSize.height +
        theme.assetIDLabelTopPadding +
        assetIDButtonSize.height +
        theme.separatorPadding +
        theme.separator.size +
        theme.bottomPadding

        if !viewModel.secondaryValue.isNilOrEmpty {
            let secondaryValueLabelSize = viewModel.secondaryValue.boundingSize(
                multiline: false,
                fittingSize: CGSize((width, .greatestFiniteMagnitude))
            )

            preferredHeight =
            preferredHeight +
            theme.secondaryValueLabelTopPadding +
            secondaryValueLabelSize.height
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AssetDetailInfoView {
    @objc
    private func notifyDelegateToCopyAssetID() {
        delegate?.assetDetailInfoViewDidTapAssetID(self, assetID: assetIDButton.title(for: .normal))
    }
}

extension AssetDetailInfoView {
    private func addYourBalanceTitleLabel(
        _ theme: AssetDetailInfoViewTheme
    ) {
        yourBalanceTitleLabel.customizeAppearance(theme.yourBalanceTitleLabel)

        addSubview(yourBalanceTitleLabel)
        yourBalanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addBalanceLabel(
        _ theme: AssetDetailInfoViewTheme
    ) {
        balanceLabel.customizeAppearance(theme.balanceLabel)

        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(yourBalanceTitleLabel.snp.bottom).offset(theme.balanceLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSecondaryValueLabel(
        _ theme: AssetDetailInfoViewTheme
    ) {
        secondaryValueLabel.customizeAppearance(theme.secondaryValueLabel)

        addSubview(secondaryValueLabel)
        secondaryValueLabel.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        secondaryValueLabel.contentEdgeInsets.top = theme.secondaryValueLabelTopPadding
    }

    private func addTopSeparator(
        _ theme: AssetDetailInfoViewTheme
    ) {
        topSeparator.backgroundColor = theme.separator.color

        addSubview(topSeparator)
        topSeparator.snp.makeConstraints {
            $0.top.equalTo(secondaryValueLabel.snp.bottom).offset(theme.separatorPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToHeight(theme.separator.size)
        }
    }

    private func addAssetNameLabel(
        _ theme: AssetDetailInfoViewTheme)
    {
        addSubview(assetNameView)
        assetNameView.snp.makeConstraints {
            $0.top.equalTo(topSeparator.snp.bottom).offset(theme.assetNameLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        assetNameLabel.customizeAppearance(theme.assetNameLabel)
        assetNameView.addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        verifiedImage.customizeAppearance(theme.verifiedImage)
        assetNameView.addSubview(verifiedImage)
        verifiedImage.snp.makeConstraints {
            $0.leading.equalTo(assetNameLabel.snp.trailing).offset(theme.verifiedImageHorizontalSpacing)
            $0.centerY == 0
       }
    }

    private func addAssetIDButton(
        _ theme: AssetDetailInfoViewTheme
    ) {
        assetIDButton.customizeAppearance(theme.assetIDButton)

        addSubview(assetIDButton)
        assetIDButton.snp.makeConstraints {
            $0.top.equalTo(assetNameView.snp.bottom).offset(theme.assetIDLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addBottomSeparator(
        _ theme: AssetDetailInfoViewTheme
    ) {
        bottomSeparator.backgroundColor = theme.separator.color

        addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.top.equalTo(assetIDButton.snp.bottom).offset(theme.separatorPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
            $0.fitToHeight(theme.separator.size)
        }
    }
}

protocol AssetDetailInfoViewDelegate: AnyObject {
    func assetDetailInfoViewDidTapAssetID(_ assetDetailInfoView: AssetDetailInfoView, assetID: String?)
}
