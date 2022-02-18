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
//   WCScrollOverlayFragment.swift

import Foundation
import UIKit
import MacaroonBottomOverlay

final class WCScrollOverlayFragment: BaseViewController, BottomScrollOverlayFragment {
    var isScrollEnabled: Bool = true
    lazy var scrollView: UIScrollView = UIScrollView()

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = UIColor.green
        scrollView.backgroundColor = UIColor.lightGray
    }

    override func linkInteractors() {
        super.linkInteractors()

        scrollView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentView = UIView()
        contentView.backgroundColor = .brown

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(view)
            make.edges.equalToSuperview()
        }
    }
}

extension WCScrollOverlayFragment: UIScrollViewDelegate {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        updateLayoutWhenScrollViewDidScroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateLayoutWhenScrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}
