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

//   AssetPreviewDeleteView.swift

import UIKit
import MacaroonUIKit

final class AssetPreviewDeleteView: View {
    weak var delegate: AssetPreviewDeleteViewDelegate?
    
    private lazy var imageView = AssetImageView()
    private lazy var assetTitleVerticalStackView = VStackView()
    private lazy var assetTitleHorizontalStackView = HStackView()
    private lazy var primaryAssetTitleLabel = Label()
    private lazy var secondaryImageView = ImageView()
    private lazy var secondaryAssetTitleLabel = Label()
    private lazy var assetValueVerticalStackView = VStackView()
    private lazy var primaryAssetValueLabel = Label()
    private lazy var secondaryAssetValueLabel = Label()
    private lazy var deleteButton = Button()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }
    
    func customize(_ theme: AssetPreviewDeleteViewTheme) {
        addImage(theme)
        addAssetTitleVerticalStackView(theme)
        addActionButton(theme)
        addAssetValueVerticalStackView(theme)
    }
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func setListeners() {
        deleteButton.addTarget(
            self,
            action: #selector(didTapDeleteButton),
            for: .touchUpInside
        )
    }
}

extension AssetPreviewDeleteView {
    @objc
    func didTapDeleteButton() {
        delegate?.assetPreviewDeleteViewDidDelete(self)
    }
}

extension AssetPreviewDeleteView {
    private func addImage(_ theme: AssetPreviewDeleteViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addAssetTitleVerticalStackView(_ theme: AssetPreviewDeleteViewTheme) {
        addSubview(assetTitleVerticalStackView)
        assetTitleVerticalStackView.alignment = .leading
        
        assetTitleVerticalStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }
        
        addAssetTitleHorizontalStackView(theme)
        addSecondaryAssetTitleLabel(theme)
    }
    private func addAssetTitleHorizontalStackView(_ theme: AssetPreviewDeleteViewTheme) {
        assetTitleVerticalStackView.addArrangedSubview(assetTitleHorizontalStackView)
        assetTitleHorizontalStackView.spacing = theme.secondaryImageLeadingPadding
        
        addPrimaryAssetTitleLabel(theme)
        addSecondaryImage(theme)
    }
    private func addPrimaryAssetTitleLabel(_ theme: AssetPreviewDeleteViewTheme) {
        primaryAssetTitleLabel.customizeAppearance(theme.primaryAssetTitle)
        primaryAssetTitleLabel.adjustsFontSizeToFitWidth = false
        
        assetTitleHorizontalStackView.addArrangedSubview(primaryAssetTitleLabel)
    }
    private func addSecondaryImage(_ theme: AssetPreviewDeleteViewTheme) {
        assetTitleHorizontalStackView.addArrangedSubview(secondaryImageView)
    }
    private func addSecondaryAssetTitleLabel(_ theme: AssetPreviewDeleteViewTheme) {
        secondaryAssetTitleLabel.customizeAppearance(theme.secondaryAssetTitle)
        secondaryAssetTitleLabel.adjustsFontSizeToFitWidth = false

        assetTitleVerticalStackView.addArrangedSubview(secondaryAssetTitleLabel)
    }
    
    private func addActionButton(_ theme: AssetPreviewDeleteViewTheme) {
        deleteButton.customizeAppearance(theme.button)
        deleteButton.draw(corner: theme.buttonCorner)
        deleteButton.draw(shadow: theme.buttonFirstShadow)
        deleteButton.draw(secondShadow: theme.buttonSecondShadow)
        deleteButton.draw(thirdShadow: theme.buttonThirdShadow)
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.fitToSize(theme.buttonSize)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addAssetValueVerticalStackView(_ theme: AssetPreviewDeleteViewTheme) {
        addSubview(assetValueVerticalStackView)
        assetValueVerticalStackView.alignment = .trailing

        assetValueVerticalStackView.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-theme.assetValueTrailingPadding)
            $0.leading.equalTo(assetTitleVerticalStackView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(assetTitleVerticalStackView.snp.centerY)
        }

        addPrimaryAssetValueLabel(theme)
        addSecondaryAssetValueLabel(theme)
    }
    private func addPrimaryAssetValueLabel(_ theme: AssetPreviewDeleteViewTheme) {
        primaryAssetValueLabel.customizeAppearance(theme.primaryAssetValue)

        assetValueVerticalStackView.addArrangedSubview(primaryAssetValueLabel)
    }

    private func addSecondaryAssetValueLabel(_ theme: AssetPreviewDeleteViewTheme) {
        secondaryAssetValueLabel.customizeAppearance(theme.secondaryAssetValue)

        assetValueVerticalStackView.addArrangedSubview(secondaryAssetValueLabel)
    }
}

extension AssetPreviewDeleteView: ViewModelBindable {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        imageView.bindData(viewModel?.assetImageViewModel)
        primaryAssetTitleLabel.editText = viewModel?.assetPrimaryTitle
        secondaryImageView.image = viewModel?.secondaryImage
        secondaryAssetTitleLabel.editText = viewModel?.assetSecondaryTitle
        primaryAssetValueLabel.editText = viewModel?.assetPrimaryValue
        secondaryAssetValueLabel.editText = viewModel?.assetSecondaryAssetValue
    }
    
    func prepareForReuse() {
        imageView.prepareForReuse()
        secondaryImageView.image = nil
        primaryAssetTitleLabel.text = nil
        secondaryAssetTitleLabel.text = nil
        primaryAssetValueLabel.text = nil
        secondaryAssetValueLabel.text = nil
    }
}

protocol AssetPreviewDeleteViewDelegate: AnyObject {
    func assetPreviewDeleteViewDidDelete(_ assetPreviewDeleteView: AssetPreviewDeleteView)
}

