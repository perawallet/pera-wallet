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
//  AssetNameView.swift

import UIKit

class AssetNameView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private lazy var verifiedImageView = UIImageView(image: img("icon-verified"))
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var codeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var idLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupVerifiedImageViewLayout()
        setupNameLabelLayout()
        setupCodeLabelLayout()
        setupIdLabelLayout()
    }
}

extension AssetNameView {
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.imageSize)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.labelInset)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().priority(.medium)
            make.bottom.equalToSuperview().priority(.medium)
            make.trailing.lessThanOrEqualToSuperview().priority(.medium)
        }
    }

    private func setupCodeLabelLayout() {
        addSubview(codeLabel)
        
        codeLabel.snp.makeConstraints { make in
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.labelInset)
            make.bottom.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(layout.current.codeLabelOffset)
            make.top.equalToSuperview().priority(.medium)
            make.leading.equalToSuperview().priority(.medium)
            make.trailing.lessThanOrEqualToSuperview().priority(.medium)
        }
    }
    
    private func setupIdLabelLayout() {
        addSubview(idLabel)
        
        idLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        idLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        idLabel.snp.makeConstraints { make in
            make.leading.equalTo(codeLabel.snp.trailing).offset(layout.current.codeLabelOffset)
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.labelInset).priority(.medium)
            make.leading.equalToSuperview().priority(.low)
            make.top.equalTo(nameLabel.snp.bottom).offset(layout.current.codeLabelOffset)
            make.top.equalToSuperview().priority(.medium)
            make.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension AssetNameView {
    func setAssetName(for assetDetail: AssetInformation) {
        if assetDetail.hasDisplayName() {
            nameLabel.text = assetDetail.name
            codeLabel.text = assetDetail.unitName
        } else {
            nameLabel.text = "title-unknown".localized
        }
        
        idLabel.text = "· \(assetDetail.id)"
    }
    
    func setAlignment(_ alignment: NSTextAlignment) {
        nameLabel.textAlignment = alignment
        codeLabel.textAlignment = alignment
        idLabel.textAlignment = alignment
    }
    
    func removeName() {
        nameLabel.removeFromSuperview()
    }
    
    func removeUnitName() {
        codeLabel.removeFromSuperview()
    }
    
    func removeVerified() {
        verifiedImageView.removeFromSuperview()
    }
    
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setCode(_ code: String?) {
        codeLabel.text = code
    }
    
    func setId(_ id: String?) {
        idLabel.text = id
    }
    
    func removeId() {
        idLabel.removeFromSuperview()
    }
}

extension AssetNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let codeLabelOffset: CGFloat = 4.0
        let labelInset: CGFloat = 8.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let horizontalInset: CGFloat = 20.0
    }
}
