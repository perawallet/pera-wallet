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
//  BannerDisplayable.swift

import UIKit

protocol BannerDisplayable {
    var statusBarView: UIView { get }
    var shouldDisplayBanner: Bool { get }
    func addBanner()
    func removeBanner()
}

extension BannerDisplayable where Self: UIViewController {
    func addBanner() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        if !shouldDisplayBanner {
            removeBanner()
            return
        }

        if statusBarView.superview != nil {
            return
        }

        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        window.addSubview(statusBarView)

        statusBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(statusBarHeight)
            make.top.leading.trailing.equalToSuperview()
        }
    }

    func removeBanner() {
        if statusBarView.superview != nil {
            statusBarView.removeFromSuperview()
        }
    }
}
