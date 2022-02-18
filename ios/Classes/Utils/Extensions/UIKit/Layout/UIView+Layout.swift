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
//  UIView+Layout.swift

import UIKit

extension UIView {
    func prepareWholeScreenLayoutFor(_ subview: UIView) {
        addSubview(subview)
        subview.pinToSuperview()
    }

    func pinToSuperview() {
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func showViewInStack() {
        isHidden = false
    }

    func hideViewInStack() {
        isHidden = true
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
