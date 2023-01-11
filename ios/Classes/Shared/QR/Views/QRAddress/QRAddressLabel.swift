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
//   QRAddressLabel.swift

import UIKit
import MacaroonUIKit

final class QRAddressLabel: View {
    private lazy var titleLabel = UILabel()
    private lazy var addressLabel = UILabel()
    
    func customize(_ theme: QRAddressLabelTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addTitle(theme)
        addAddress(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension QRAddressLabel {
    private func addTitle(_ theme: QRAddressLabelTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func addAddress(_ theme: QRAddressLabelTheme) {
        addressLabel.customizeAppearance(theme.address)
        
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.spacing)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension QRAddressLabel: ViewModelBindable {
    func bindData(_ viewModel: QRAddressLabelViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleLabel)
        } else {
            titleLabel.text = nil
            titleLabel.attributedText = nil
        }

        if let address = viewModel?.address {
            address.load(in: addressLabel)
        } else {
            addressLabel.text = nil
            addressLabel.attributedText = nil
        }
    }
}
