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
//   AssetPreviewView.swift

import MacaroonUIKit
import UIKit

final class AssetPreviewView: View {
    private lazy var imageView = AssetImageView()
    private lazy var assetTitleVerticalStackView = UIStackView()
    private lazy var assetTitleHorizontalStackView = UIStackView()
    private lazy var primaryAssetTitleLabel = UILabel()
    private lazy var secondaryImageView = UIImageView()
    private lazy var secondaryAssetTitleLabel = UILabel()
    private lazy var assetValueVerticalStackView = UIStackView()
    private lazy var primaryAssetValueLabel = UILabel()
    private lazy var secondaryAssetValueLabel = UILabel()

    func customize(_ theme: AssetPreviewViewTheme) {
        addImage(theme)
        addAssetTitleVerticalStackView(theme)
        addAssetValueVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension AssetPreviewView {
    private func addImage(_ theme: AssetPreviewViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalPadding)
        }
    }

    private func addAssetTitleVerticalStackView(_ theme: AssetPreviewViewTheme) {
        addSubview(assetTitleVerticalStackView)
        assetTitleVerticalStackView.axis = .vertical
        assetTitleVerticalStackView.alignment = .leading

        assetTitleVerticalStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }

        addAssetTitleHorizontalStackView(theme)
        addSecondaryAssetTitleLabel(theme)
    }

    private func addAssetTitleHorizontalStackView(_ theme: AssetPreviewViewTheme) {
        assetTitleVerticalStackView.addArrangedSubview(assetTitleHorizontalStackView)
        assetTitleHorizontalStackView.spacing = theme.secondaryImageLeadingPadding

        addPrimaryAssetTitleLabel(theme)
        addSecondaryImage(theme)
    }

    private func addPrimaryAssetTitleLabel(_ theme: AssetPreviewViewTheme) {
        primaryAssetTitleLabel.customizeAppearance(theme.primaryAssetTitle)
        primaryAssetTitleLabel.adjustsFontSizeToFitWidth = false

        assetTitleHorizontalStackView.addArrangedSubview(primaryAssetTitleLabel)
    }

    private func addSecondaryImage(_ theme: AssetPreviewViewTheme) {
        assetTitleHorizontalStackView.addArrangedSubview(secondaryImageView)
    }

    private func addSecondaryAssetTitleLabel(_ theme: AssetPreviewViewTheme) {
        secondaryAssetTitleLabel.customizeAppearance(theme.secondaryAssetTitle)
        secondaryAssetTitleLabel.adjustsFontSizeToFitWidth = false

        assetTitleVerticalStackView.addArrangedSubview(secondaryAssetTitleLabel)
    }

    private func addAssetValueVerticalStackView(_ theme: AssetPreviewViewTheme) {
        addSubview(assetValueVerticalStackView)
        assetValueVerticalStackView.axis = .vertical
        assetValueVerticalStackView.alignment = .trailing

        assetValueVerticalStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(assetTitleVerticalStackView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(assetTitleVerticalStackView.snp.centerY)
        }

        addPrimaryAssetValueLabel(theme)
        addSecondaryAssetValueLabel(theme)
    }

    private func addPrimaryAssetValueLabel(_ theme: AssetPreviewViewTheme) {
        primaryAssetValueLabel.customizeAppearance(theme.primaryAssetValue)

        assetValueVerticalStackView.addArrangedSubview(primaryAssetValueLabel)
    }

    private func addSecondaryAssetValueLabel(_ theme: AssetPreviewViewTheme) {
        secondaryAssetValueLabel.customizeAppearance(theme.secondaryAssetValue)

        assetValueVerticalStackView.addArrangedSubview(secondaryAssetValueLabel)
    }
}

extension AssetPreviewView: ViewModelBindable {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        imageView.bindData(
            AssetImageViewModel(
                image: viewModel?.image,
                assetAbbreviationForImage: viewModel?.assetAbbreviationForImage?.string
            )
        )
        primaryAssetTitleLabel.editText = viewModel?.assetPrimaryTitle
        secondaryImageView.image = viewModel?.secondaryImage
        secondaryAssetTitleLabel.editText = viewModel?.assetSecondaryTitle
        primaryAssetValueLabel.editText = viewModel?.assetPrimaryValue
        secondaryAssetValueLabel.editText = viewModel?.assetSecondaryAssetValue
    }

    func reset() {
        imageView.prepareForReuse()
        secondaryImageView.image = nil
        primaryAssetTitleLabel.text = nil
        secondaryAssetTitleLabel.text = nil
        primaryAssetValueLabel.text = nil
        secondaryAssetValueLabel.text = nil
    }
}

final class AssetPreviewCell: BaseCollectionViewCell<AssetPreviewView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contextView.customize(AssetPreviewViewCommonTheme())
    }

    func bindData(_ viewModel: AssetPreviewViewModel) {
        contextView.bindData(viewModel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.reset()
    }
}

final class AssetPreviewAdditionCell: BaseCollectionViewCell<AssetPreviewView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contextView.customize(AssetPreviewViewAdditionTheme())
    }

    func bindData(_ viewModel: AssetPreviewViewModel) {
        contextView.bindData(viewModel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.reset()
    }
}
