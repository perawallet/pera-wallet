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
//  SingleSelectionView.swift

import UIKit
import MacaroonUIKit

final class SingleSelectionView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var theme = SingleSelectionViewTheme()
    
    private lazy var titleLabel = UILabel()
    private lazy var selectionImageView = UIImageView()
    
    func customize(_ theme: SingleSelectionViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addSelectionImage(theme)
        addTitle(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func bindData(_ viewModel: SingleSelectionViewModel?) {
        titleLabel.text = viewModel?.title
        selectionImageView.image = viewModel?.selectionImage
    }
}

extension SingleSelectionView {
    private func addTitle(_ theme: SingleSelectionViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.trailing.equalTo(selectionImageView.snp.leading)
        }
    }
    
    private func addSelectionImage(_ theme: SingleSelectionViewTheme) {
        addSubview(selectionImageView)
        selectionImageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY.trailing.equalToSuperview()
        }
    }
}
