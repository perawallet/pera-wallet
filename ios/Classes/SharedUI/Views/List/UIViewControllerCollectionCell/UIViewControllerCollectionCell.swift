// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   UIViewControllerCollectionCell.swift

import Foundation
import UIKit

class UIViewControllerCollectionCell: UICollectionViewCell {
    weak var contextView: UIView? {
        get { getContextView() }
        set { setContextView(newValue) }
    }

    private weak var contextViewRef: UIView? {
        didSet { contextViewDidSet(old: oldValue) }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView = nil
    }
}

extension UIViewControllerCollectionCell {
    private func getContextView() -> UIView? {
        if !containsSubview(contextViewRef) {
            contextViewRef = nil
        }

        return contextViewRef
    }

    private func setContextView(_ newContextView: UIView?) {
        contextViewRef = newContextView
    }

    private func contextViewDidSet(old oldContextView: UIView?) {
        if containsSubview(oldContextView) {
            oldContextView?.removeFromSuperview()
        }

        if let newContextView = contextViewRef {
            newContextView.frame = contentView.bounds
            contentView.addSubview(newContextView)
        }
    }
}
