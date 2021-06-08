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
//  AssetDisplayView.swift

import UIKit

class AssetDisplayView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Background.secondary
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    private(set) lazy var assetIndexLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var copyButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-copy", isTemplate: true)).withTintColor(Colors.Main.gray300)
    }()
    
    private lazy var assetCodeLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .bold(size: 28.0)))
            .withTextColor(Colors.General.selected)
    }()
    
    private lazy var assetNameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        layer.cornerRadius = 12.0
        if !isDarkModeDisplay {
            topContainerView.applySmallShadow()
        }
    }
    
    override func setListeners() {
        copyButton.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTopContainerViewLayout()
        setupVerifiedImageViewLayout()
        setupCopyButtonLayout()
        setupAssetIndexLabelLayout()
        setupAssetCodeLabelLayout()
        setupAssetNameLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            topContainerView.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            topContainerView.removeShadows()
        } else {
            topContainerView.applySmallShadow()
        }
    }
}

extension AssetDisplayView {
    @objc
    private func didTapCopyButton() {
        NotificationBanner.showInformation("asset-id-copied-title".localized)
        UIPasteboard.general.string = assetIndexLabel.text
    }
}

extension AssetDisplayView {
    private func setupTopContainerViewLayout() {
        addSubview(topContainerView)
        
        topContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.containerInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.containerInset)
            make.height.equalTo(44.0)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        topContainerView.addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.verifiedImageLeadingInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupCopyButtonLayout() {
        topContainerView.addSubview(copyButton)
        
        copyButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(layout.current.copyButtonTrailingInset)
            make.size.equalTo(layout.current.copyButtonSize)
        }
    }
    
    private func setupAssetIndexLabelLayout() {
        topContainerView.addSubview(assetIndexLabel)
        
        assetIndexLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(verifiedImageView.snp.trailing).offset(layout.current.indexLabelInset)
            make.trailing.lessThanOrEqualTo(copyButton.snp.leading).offset(-layout.current.indexLabelInset)
        }
    }
    
    private func setupAssetCodeLabelLayout() {
        addSubview(assetCodeLabel)
        
        assetCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(assetCodeLabel.snp.bottom).offset(layout.current.nameTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension AssetDisplayView {
    func bind(_ viewModel: AssetDisplayViewModel) {
        verifiedImageView.isHidden = !viewModel.isVerified
        assetNameLabel.text = viewModel.name
        assetCodeLabel.text = viewModel.code

        if let codeFont = viewModel.codeFont {
            assetCodeLabel.font = codeFont
        }

        if let codeColor = viewModel.codeColor {
            assetCodeLabel.textColor = codeColor
        }
    }
}

extension AssetDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let containerInset: CGFloat = 8.0
        let verifiedImageLeadingInset: CGFloat = 12.0
        let indexLabelInset: CGFloat = 12.0
        let copyButtonTrailingInset: CGFloat = 10.0
        let horizontalInset: CGFloat = 20.0
        let copyButtonSize = CGSize(width: 30.0, height: 30.0)
        let nameTopInset: CGFloat = 4.0
        let verticalInset: CGFloat = 20.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
    }
}
