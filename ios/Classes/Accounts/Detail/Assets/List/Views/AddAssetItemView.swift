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
//   AddAssetItemView.swift

import UIKit
import MacaroonUIKit

final class AddAssetItemView: View {
    weak var delegate: AddAssetItemViewDelegate?

    private lazy var addButton = Button(.imageAtLeft(spacing: 16))

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(AddAssetItemViewTheme())
        setListeners()
    }

    private func customize(_ theme: AddAssetItemViewTheme) {
        addAddButton(theme)
    }

    func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddButtonTapped), for: .touchUpInside)
    }

    func prepareLayout(_ layoutSheet: AddAssetItemViewTheme) {}

    func customizeAppearance(_ styleSheet: AddAssetItemViewTheme) {}
}

extension AddAssetItemView {
    private func addAddButton(_ theme: AddAssetItemViewTheme) {
        addButton.customizeAppearance(theme.button)

        addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.iconLeadingInset)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension AddAssetItemView {
    @objc
    private func notifyDelegateToAddButtonTapped() {
        delegate?.addAssetItemViewDidTapAddAsset(self)
    }
}

protocol AddAssetItemViewDelegate: AnyObject {
    func addAssetItemViewDidTapAddAsset(_ addAssetItemView: AddAssetItemView)
}

final class AddAssetItemCell: BaseCollectionViewCell<AddAssetItemView> {

    override func configureAppearance() {
        super.configureAppearance()

        contextView.isUserInteractionEnabled = false
    }
    
}
