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
//  UIStackView+Additions.swift

import UIKit

extension UIStackView {
    /// <todo>
    /// Move it to 'Macaroon' later.
    func insertArrangedSubview(
        _ view: UIView,
        preferredAt index: Int?
    ) {
        if let index = index {
            insertArrangedSubview(
                view,
                at: index
            )
        } else {
            addArrangedSubview(view)
        }
    }
}

extension UIStackView {
    func deleteAllArrangedSubviews() {
        arrangedSubviews.forEach { deleteArrangedSubview($0) }
    }

    func deleteArrangedSubview(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}
