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

//   CollectibleMediaImagePreviewView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleMediaImagePreviewView:
    View,
    ViewModelBindable,
    ListReusable {
    lazy var handlers = Handlers()

    private lazy var image = URLImageView()
    private lazy var overlayView = UIView()

    var currentImage: UIImage? {
        return image.imageContainer.image
    }

    func customize(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        addImage(theme)
        addOverlayView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectibleMediaImagePreviewView {
    private func addImage(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        image.build(theme.image)
        image.layer.draw(corner: theme.corner)
        image.clipsToBounds = true

        addSubview(image)
        image.fitToIntrinsicSize()
        image.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addOverlayView(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        overlayView.customizeAppearance(theme.overlay)
        overlayView.layer.draw(corner: theme.corner)
        overlayView.clipsToBounds = true
        overlayView.alpha = 0.0

        image.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension CollectibleMediaImagePreviewView {
    func bindData(
        _ viewModel: CollectibleMediaImagePreviewViewModel?
    ) {
        image.load(from: viewModel?.image) {
            [weak self] _ in
            guard let self = self,
                  let image = self.image.imageContainer.image else {
                return
            }

            self.handlers.didLoadImage?(image)
        }

        guard let viewModel = viewModel else {
            return
        }

        if !viewModel.isOwned {
            overlayView.alpha = 0.4
        } else {
            overlayView.alpha = 0.0
        }
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleMediaImagePreviewViewModel?,
        for theme: CollectibleMediaImagePreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return CGSize((size.width, size.height))
    }
}

extension CollectibleMediaImagePreviewView {
    func prepareForReuse() {
        overlayView.alpha = 0.0
        image.prepareForReuse()
    }
}

extension CollectibleMediaImagePreviewView {
    struct Handlers {
        var didLoadImage: ((UIImage) -> Void)?
    }
}
