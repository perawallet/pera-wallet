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
    var footerBackgroundEffect: Effect? {
        get { footerBackgroundView.effect }
        set { footerBackgroundView.effect = newValue }
    }

    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = ScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isAutoScrollingToEditingTextFieldEnabled = isAutoScrollingToEditingTextFieldEnabled
        return scrollView
    }()
    
    private(set) lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()

    private(set) lazy var footerView: UIView = .init()
    private(set) lazy var footerBackgroundView = EffectView()

    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        return .never
    }
    var contentSizeBehaviour: ContentSizeBehaviour {
        return .scrollableAreaAtMinumum
    }
    var isAutoScrollingToEditingTextFieldEnabled: Bool = true
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addScroll()
        addFooter()
    }

    private func addScroll() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addContent()
    }

    private func addContent() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width == view
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0

            switch contentSizeBehaviour {
            case .intrinsic:
                break
            case .scrollableAreaAtMinumum:
                $0.height.equalToSuperview().priority(.low)
            }
        }
    }

    func addFooter() {
        view.addSubview(footerBackgroundView)
        footerBackgroundView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        footerBackgroundView.addSubview(footerView)
        footerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == footerBackgroundView.safeAreaLayoutGuide.snp.bottom
            $0.trailing == 0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if contentView.bounds.isEmpty {
            return
        }

        updateScrollLayoutWhenViewDidLayoutSubviews()
        updateLayoutOnScroll()
    }

    private func updateLayoutOnScroll() {
        if footerView.bounds.isEmpty {
            return
        }

        let endOfContent = contentView.frame.maxY - scrollView.contentOffset.y
        let hidesFooterBackgroundEffect = endOfContent <= footerBackgroundView.frame.minY
        footerBackgroundView.setEffectHidden(hidesFooterBackgroundEffect)
    }

    private func updateScrollLayoutWhenViewDidLayoutSubviews() {
        if !footerView.bounds.isEmpty {
            scrollView.setContentInset(bottom: footerView.bounds.height)
        }
    }
}

extension BaseScrollViewController {
    enum ContentSizeBehaviour {
        case intrinsic
        case scrollableAreaAtMinumum
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
        let footerSize = footerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return contentSize.height + footerSize.height
    }
}

final class ScrollView: UIScrollView {
    var isAutoScrollingToEditingTextFieldEnabled: Bool = true

    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        guard isAutoScrollingToEditingTextFieldEnabled else {
            return
        }

        super.scrollRectToVisible(rect, animated: animated)
    }
}
