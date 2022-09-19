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
//  BaseScrollViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonStorySheet
import MacaroonUIKit
import UIKit

class BaseScrollViewController: BaseViewController {
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = TouchDetectingScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private(set) lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupScrollViewLayout()
        setupContentViewLayout()
    }
}

extension BaseScrollViewController {
    private func setupScrollViewLayout() {
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupContentViewLayout() {
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.leading.trailing.equalTo(view)
            make.height.equalToSuperview().priority(.low)
        }
    }
}

extension BottomSheetScrollPresentable where Self: BaseScrollViewController {
    var modalHeight: ModalHeight {
        return .compressed
    }

    func calculateContentAreaHeightFitting(_ targetSize: CGSize) -> CGFloat {
        let contentSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return contentSize.height
    }
}
