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

//   CollectibleMediaImagePreviewCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleMediaImagePreviewCell:
    CollectionCell<CollectibleMediaImagePreviewView>,
    ViewModelBindable {
    lazy var handlers = Handlers()
    
    static let theme = CollectibleMediaImagePreviewViewTheme()

    override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        contextView.customize(Self.theme)
    }

    override func setListeners() {
        contextView.handlers.didLoadImage = {
            [weak self] image in
            guard let self else {
                return
            }

            self.handlers.didLoadImage?(image)
        }
        contextView.handlers.didTap3DModeAction = {
            [weak self] in
            guard let self else {
                return
            }

            self.handlers.didTap3DModeAction?()
        }
        contextView.handlers.didTapFullScreenAction = {
            [weak self] in
            guard let self else {
                return
            }

            self.handlers.didTapFullScreenAction?()
        }
    }
}

extension CollectibleMediaImagePreviewCell {
    struct Handlers {
        var didLoadImage: ((UIImage) -> Void)?
        var didTap3DModeAction: (() -> Void)?
        var didTapFullScreenAction: (() -> Void)?
    }
}
