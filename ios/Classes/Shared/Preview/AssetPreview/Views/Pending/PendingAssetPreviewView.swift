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
//   PendingAssetPreviewView.swift

import MacaroonUIKit
import UIKit

final class PendingAssetPreviewView: View {
    private lazy var imageView = PendingAssetImageView()
    private lazy var assetTitleVerticalStackView = UIStackView()
    private lazy var assetTitleHorizontalStackView = UIStackView()
    private lazy var primaryAssetTitleLabel = UILabel()
    private lazy var secondaryImageView = UIImageView()
    private lazy var secondaryAssetTitleLabel = UILabel()
    private lazy var assetStatusLabel = UILabel()

    func customize(_ theme: PendingAssetPreviewViewTheme) {
        addImage(theme)
        addAssetTitleVerticalStackView(theme)
        addAssetStatusLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PendingAssetPreviewView {
    private func addImage(_ theme: PendingAssetPreviewViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalPadding)
        }
    }

    private func addAssetTitleVerticalStackView(_ theme: PendingAssetPreviewViewTheme) {
        addSubview(assetTitleVerticalStackView)
        assetTitleVerticalStackView.axis = .vertical

        assetTitleVerticalStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }

        addAssetTitleHorizontalStackView(theme)
        addSecondaryAssetTitleLabel(theme)
    }

    private func addAssetTitleHorizontalStackView(_ theme: PendingAssetPreviewViewTheme) {
        assetTitleVerticalStackView.addArrangedSubview(assetTitleHorizontalStackView)
        assetTitleHorizontalStackView.spacing = theme.secondaryImageLeadingPadding

        addPrimaryAssetTitleLabel(theme)
        addSecondaryImage(theme)
    }

    private func addPrimaryAssetTitleLabel(_ theme: PendingAssetPreviewViewTheme) {
        primaryAssetTitleLabel.customizeAppearance(theme.primaryAssetTitle)
        primaryAssetTitleLabel.adjustsFontSizeToFitWidth = false

        assetTitleHorizontalStackView.addArrangedSubview(primaryAssetTitleLabel)
    }

    private func addSecondaryImage(_ theme: PendingAssetPreviewViewTheme) {
        assetTitleHorizontalStackView.addArrangedSubview(secondaryImageView)
    }

    private func addSecondaryAssetTitleLabel(_ theme: PendingAssetPreviewViewTheme) {
        secondaryAssetTitleLabel.customizeAppearance(theme.secondaryAssetTitle)
        secondaryAssetTitleLabel.adjustsFontSizeToFitWidth = false

        assetTitleVerticalStackView.addArrangedSubview(secondaryAssetTitleLabel)
    }

    private func addAssetStatusLabel(_ theme: PendingAssetPreviewViewTheme) {
        assetStatusLabel.customizeAppearance(theme.assetStatus)
        addSubview(assetStatusLabel)

        assetStatusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(assetTitleVerticalStackView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(assetTitleVerticalStackView.snp.centerY)
        }
    }
}

extension PendingAssetPreviewView: ViewModelBindable {
    func bindData(_ viewModel: PendingAssetPreviewViewModel?) {
        imageView.startLoading()
        primaryAssetTitleLabel.text = viewModel?.assetPrimaryTitle
        secondaryImageView.image = viewModel?.secondaryImage
        secondaryAssetTitleLabel.text = viewModel?.assetSecondaryTitle
        assetStatusLabel.text = viewModel?.assetStatus
    }

    func reset() {
        imageView.prepareForReuse()
        secondaryImageView.image = nil
        primaryAssetTitleLabel.text = nil
        secondaryAssetTitleLabel.text = nil
        assetStatusLabel.text = nil
    }
}

final class PendingAssetPreviewCell: BaseCollectionViewCell<PendingAssetPreviewView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contextView.customize(PendingAssetPreviewViewTheme())
    }

    func bindData(_ viewModel: PendingAssetPreviewViewModel) {
        contextView.bindData(viewModel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.reset()
    }
}
