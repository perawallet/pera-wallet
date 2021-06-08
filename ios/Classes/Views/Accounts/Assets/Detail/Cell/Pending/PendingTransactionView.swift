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
//  PendingTransactionView.swift

import UIKit

class PendingTransactionView: TransactionHistoryContextView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var pendingImageView = UIImageView(image: img("icon-pending"))
    
    override func prepareLayout() {
        super.prepareLayout()
        adjustTitleLabelLayout()
        setupPendingImageViewLayout()
    }
}

extension PendingTransactionView {
    private func adjustTitleLabelLayout() {
        contactLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLabelInset)
        }
        
        addressLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLabelInset)
        }
    }
    
    private func setupPendingImageViewLayout() {
        addSubview(pendingImageView)
        
        pendingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
}

extension PendingTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let titleLabelInset: CGFloat = 56.0
    }
}
