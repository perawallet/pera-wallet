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
//  TransactionAssetView.swift

import UIKit

class TransactionAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var assetNameView = AssetNameView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = .clear
        titleLabel.text = "asset-title".localized
    }
    
    override func prepareLayout() {
        setupAssetNameViewLayout()
        setupTitleLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionAssetView {
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(assetNameView)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualTo(assetNameView.snp.leading).offset(-layout.current.minimumOffset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension TransactionAssetView {
    func setAssetName(for assetDetail: AssetDetail) {
        assetNameView.setAssetName(for: assetDetail)
    }
    
    func removeVerifiedAsset() {
        assetNameView.removeVerified()
    }
    
    func setAssetName(_ name: String?) {
        assetNameView.setName(name)
    }
    
    func setAssetCode(_ code: String?) {
        assetNameView.setCode(code)
    }
    
    func setAssetId(_ id: String?) {
        assetNameView.setId(id)
    }
    
    func removeAssetId() {
        assetNameView.removeId()
    }
    
    func removeAssetName() {
        assetNameView.removeName()
    }
    
    func removeAssetUnitName() {
        assetNameView.removeUnitName()
    }
    
    func setAssetAlignment(_ alignment: NSTextAlignment) {
        assetNameView.setAlignment(alignment)
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        separatorView.isHidden = hidden
    }
}

extension TransactionAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let minimumOffset: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
    }
}
