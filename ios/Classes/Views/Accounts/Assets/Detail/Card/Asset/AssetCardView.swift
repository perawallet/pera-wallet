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
//  AssetCardView.swift

import UIKit

class AssetCardView: BaseView {
    
    weak var delegate: AssetCardViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-card-gray"))
    
    private lazy var assetNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var verifiedImageView = UIImageView(image: img("icon-verified-white"))
    
    private lazy var assetNameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var assetAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var assetIDButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 8.0))
        button.setImage(img("icon-copy", isTemplate: true), for: .normal)
        button.tintColor = Colors.Main.white
        button.setTitleColor(Colors.Main.white, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .regular(size: 12.0))
        button.titleLabel?.textAlignment = .left
        return button
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func setListeners() {
        assetIDButton.addTarget(self, action: #selector(notifyDelegateToCopyAssetId), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupAssetNameStackViewLayout()
        setupAssetAmountLabelLayout()
        setupAssetIdButtonLayout()
    }
}

extension AssetCardView {
    @objc
    private func notifyDelegateToCopyAssetId() {
        delegate?.assetCardViewDidCopyAssetId(self)
    }
}

extension AssetCardView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupAssetNameStackViewLayout() {
        addSubview(assetNameStackView)
        
        assetNameStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
        }
        
        assetNameStackView.addArrangedSubview(verifiedImageView)
        assetNameStackView.addArrangedSubview(assetNameLabel)
    }
    
    private func setupAssetAmountLabelLayout() {
        addSubview(assetAmountLabel)
        
        assetAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(assetNameStackView.snp.bottom).offset(layout.current.amountTopInset)
        }
    }
    
    private func setupAssetIdButtonLayout() {
        addSubview(assetIDButton)
        
        assetIDButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension AssetCardView {
    func bind(_ viewModel: AssetCardViewModel) {
        verifiedImageView.isHidden = !viewModel.isVerified
        assetNameLabel.text = viewModel.name
        assetAmountLabel.text = viewModel.amount
        assetIDButton.setTitle(viewModel.id, for: .normal)
    }
}

extension AssetCardView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 24.0
        let amountTopInset: CGFloat = 44.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol AssetCardViewDelegate: AnyObject {
    func assetCardViewDidCopyAssetId(_ assetCardView: AssetCardView)
}
