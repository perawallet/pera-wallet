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

    private(set) lazy var imageView = URLImageView()
    private lazy var overlayView = UIImageView()
    private lazy var threeDModeActionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    private lazy var fullScreenActionView = MacaroonUIKit.Button()

    var currentImage: UIImage? {
        return imageView.imageContainer.image
    }

    func customize(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        addImage(theme)
        addOverlayView(theme)
        add3DModeAction(theme)
        addFullScreenAction(theme)
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
        imageView.build(theme.image)
        imageView.layer.draw(corner: theme.corner)
        imageView.clipsToBounds = true

        addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addOverlayView(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func add3DModeAction(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        threeDModeActionView.customizeAppearance(theme.threeDAction)

        addSubview(threeDModeActionView)
        threeDModeActionView.contentEdgeInsets = UIEdgeInsets(theme.threeDActionContentEdgeInsets)
        threeDModeActionView.snp.makeConstraints {
            $0.leading == theme.threeDModeActionPaddings.leading
            $0.bottom == theme.threeDModeActionPaddings.bottom
        }

        threeDModeActionView.addTouch(
            target: self,
            action: #selector(didTap3DModeAction)
        )

        threeDModeActionView.isHidden = true
    }

    private func addFullScreenAction(
        _ theme: CollectibleMediaImagePreviewViewTheme
    ) {
        fullScreenActionView.customizeAppearance(theme.fullScreenAction)

        addSubview(fullScreenActionView)
        fullScreenActionView.snp.makeConstraints {
            $0.trailing == theme.fullScreenBadgePaddings.trailing
            $0.bottom == theme.fullScreenBadgePaddings.bottom
        }

        fullScreenActionView.addTouch(
            target: self,
            action: #selector(didTapFullScreenAction)
        )

        fullScreenActionView.isHidden = true
    }
}

extension CollectibleMediaImagePreviewView {
    @objc
    private func didTapFullScreenAction() {
        handlers.didTapFullScreenAction?()
    }

    @objc
    private func didTap3DModeAction() {
        handlers.didTap3DModeAction?()
    }
}

extension CollectibleMediaImagePreviewView {
    func bindData(
        _ viewModel: CollectibleMediaImagePreviewViewModel?
    ) {
        guard let viewModel else {
            prepareForReuse()
            return
        }

        imageView.load(from: viewModel.image) {
            [weak self] _ in
            guard let self else {
                return
            }

            guard let image = self.imageView.imageContainer.image else {
                updateUIForImageState(
                    isImageLoaded: false,
                    viewModel: viewModel
                )
                return
            }

            self.handlers.didLoadImage?(image)

            updateUIForImageState(
                isImageLoaded: true,
                viewModel: viewModel
            )
        }

        overlayView.image = viewModel.overlayImage
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
        overlayView.image = nil
        imageView.prepareForReuse()
        threeDModeActionView.isHidden = true
        fullScreenActionView.isHidden = true
    }
}

extension CollectibleMediaImagePreviewView {
    private func updateUIForImageState(
        isImageLoaded: Bool,
        viewModel: CollectibleMediaImagePreviewViewModel
    ) {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: {
                [weak self] in
                guard let self else {
                    return
                }

                guard isImageLoaded else {
                    self.threeDModeActionView.isHidden = true
                    self.fullScreenActionView.isHidden = true
                    return
                }

                self.threeDModeActionView.isHidden = viewModel.is3DModeActionHidden
                self.fullScreenActionView.isHidden = viewModel.isFullScreenActionHidden
            }
        )
    }
}

extension CollectibleMediaImagePreviewView {
    struct Handlers {
        var didLoadImage: ((UIImage) -> Void)?
        var didTap3DModeAction: (() -> Void)?
        var didTapFullScreenAction: (() -> Void)?
    }
}
