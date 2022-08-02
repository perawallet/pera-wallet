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

//   FullScreenContentViewController.swift

import Foundation
import UIKit
import MacaroonUIKit
import SnapKit

class FullScreenContentViewController:
    BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return configuration.api!.isTestNet ? .darkContent : .lightContent
    }

    private lazy var backgroundView = MacaroonUIKit.BaseView()
    private lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var closeActionView = MacaroonUIKit.Button()

    private var contentTopConstraint: Constraint?
    private var contentLeadingConstraint: Constraint?
    private var contentBottomConstraint: Constraint?
    private var contentTrailingConstraint: Constraint?

    private var isAnimating = false
    private var lastLocation: CGPoint = .zero
    private var maxZoomScale: CGFloat = 1

    private let theme: FullScreenContentViewControllerTheme

    private var zoomGestureRecognizers: [UIGestureRecognizer] = []

    var isZoomingEnabled = true {
        didSet {
            scrollView.pinchGestureRecognizer?.isEnabled = isZoomingEnabled

            zoomGestureRecognizers.forEach {
                $0.isEnabled = isZoomingEnabled
            }
        }
    }

    init(
        theme: FullScreenContentViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /// <note>: This must be called in viewDidAppear or later as otherwise the system resets it to enabled.
        scrollView.pinchGestureRecognizer?.isEnabled = isZoomingEnabled
    }

    override func prepareLayout() {
        super.prepareLayout()

        addBackgroundView()
        addScrollView()
        addContentView()
        addCloseActionView()
    }

    override func setListeners() {
        super.setListeners()

        closeActionView.addTouch(
            target: self,
            action: #selector(didTapCloseButton)
        )

        addPanGesture()
        addPinchGesture()

        let singleTapGesture = addSingleTapGesture()
        let doubleTapGesture = addDoubleTapGesture()

        singleTapGesture.require(
            toFail: doubleTapGesture
        )
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let size = view.bounds.size

        updateContentConstraints(
            for: size
        )
        updateMinMaxZoomScale(
            for: size
        )
    }
}

extension FullScreenContentViewController {
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didPan)
        )
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        scrollView.addGestureRecognizer(panGesture)
    }

    private func addPinchGesture() {
        let pinchGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didPinch)
        )
        pinchGesture.numberOfTapsRequired = 1
        pinchGesture.numberOfTouchesRequired = 2
        scrollView.addGestureRecognizer(pinchGesture)

        zoomGestureRecognizers.append(pinchGesture)
    }

    private func addSingleTapGesture() -> UITapGestureRecognizer {
        let singleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didSingleTap)
        )
        scrollView.addGestureRecognizer(singleTapGesture)

        zoomGestureRecognizers.append(singleTapGesture)

        return singleTapGesture
    }

    private func addDoubleTapGesture() -> UITapGestureRecognizer {
        let doubleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didDoubleTap)
        )
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapGesture)

        zoomGestureRecognizers.append(doubleTapGesture)

        return doubleTapGesture
    }
}

extension FullScreenContentViewController {
    @objc
    private func didPan(
        _ recognizer: UIPanGestureRecognizer
    ) {
        guard !isAnimating,
              scrollView.zoomScale == scrollView.minimumZoomScale else {
            return
        }

        if recognizer.state == .began {
            lastLocation = contentView.center
        }

        if recognizer.state != .cancelled {
            let translation = recognizer.translation(in: view)
            contentView.center = CGPoint(
                x: lastLocation.x + translation.x,
                y: lastLocation.y + translation.y
            )
        }

        let diffY = view.center.y - contentView.center.y

        let minAlpha = 0.2
        backgroundView.alpha = 1 - min((1 - minAlpha), abs(diffY / view.center.y))

        UIView.animate(withDuration: 0.2) {
            self.closeActionView.alpha = 0
        }

        if recognizer.state == .ended {
            if abs(diffY) > 80 {
                dismissScreen()
                return
            }

            cancelAnimation()
        }
    }

    @objc
    func didSingleTap(
        _ recognizer: UITapGestureRecognizer
    ) {
        if contentView.frame.intersects(closeActionView.frame) {
            return
        }

        UIView.animate(withDuration: 0.2) {
            self.closeActionView.alpha = self.closeActionView.alpha > 0.5 ? 0 : 1
        }
    }

    @objc
    func didPinch(
        _ recognizer: UITapGestureRecognizer
    ) {
        var newZoomScale = scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, scrollView.minimumZoomScale)

        scrollView.setZoomScale(
            newZoomScale,
            animated: true
        )
    }

    @objc
    func didDoubleTap(
        _ recognizer: UITapGestureRecognizer
    ) {
        let pointInView = recognizer.location(in: contentView)

        zoomInOrOut(
            at: pointInView
        )
    }

    private func cancelAnimation() {
        isAnimating = true

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.contentView.center = self.view.center
                self.backgroundView.alpha = 1
                self.closeActionView.alpha = 1
            },
            completion: {
                [weak self] _ in
                self?.isAnimating = false
            }
        )
    }
}

extension FullScreenContentViewController {
    @objc
    private func didTapCloseButton() {
        dismissScreen()
    }
}

extension FullScreenContentViewController {
    private func addBackgroundView() {
        backgroundView.customizeAppearance(theme.background)

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges == 0
        }
    }

    private func addScrollView() {
        scrollView.decelerationRate = .fast
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges == 0
        }
    }

    private func addContentView() {
        contentView.layer.draw(corner: theme.contentCorner)
        contentView.clipsToBounds = true

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            contentTopConstraint = $0.top == 0
            contentLeadingConstraint = $0.leading == 0
            contentBottomConstraint = $0.bottom == 0
            contentTrailingConstraint = $0.trailing == 0

            $0.width == view.snp.width
            $0.height == contentView.snp.width
        }
    }

    private func addCloseActionView() {
        closeActionView.customizeAppearance(theme.close)

        view.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.leading == theme.closeActionLeadingPadding
            $0.top == view.safeAreaTop + theme.closeActionTopPadding
            $0.fitToSize(theme.closeActionSize)
        }
    }
}

extension FullScreenContentViewController: UIScrollViewDelegate {
    func viewForZooming(
        in scrollView: UIScrollView
    ) -> UIView? {
        return contentView
    }

    func scrollViewDidZoom(
        _ scrollView: UIScrollView
    ) {
        updateContentConstraints(
            for: view.bounds.size
        )

        hideCloseActionViewIfNeeded()
    }
}

extension FullScreenContentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard scrollView.zoomScale == scrollView.minimumZoomScale,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        let velocity = panGesture.velocity(in: scrollView)

        return abs(velocity.y) > abs(velocity.x)
    }
}

extension FullScreenContentViewController {
    private func updateContentConstraints(
        for size: CGSize
    ) {
        let yOffset = max(
            0,
            (size.height - contentView.frame.height) / 2
        )

        contentTopConstraint?.update(offset: yOffset)
        contentBottomConstraint?.update(offset: yOffset)

        let xOffset = max(
            0,
            (size.width - contentView.frame.width) / 2
        )

        contentLeadingConstraint?.update(offset: xOffset)
        contentTrailingConstraint?.update(offset: xOffset)

        view.layoutIfNeeded()
    }

    private func updateMinMaxZoomScale(
        for size: CGSize
    ) {
        let targetSize = contentView.bounds.size

        if targetSize.width == 0 ||
            targetSize.height == 0 {
            return
        }

        let minScale = min(
            size.width / targetSize.width,
            size.height / targetSize.height
        )

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale

        let maxScale = max(
            (size.width + 1) / targetSize.width,
            (size.height + 1) / targetSize.height
        )

        maxZoomScale = maxScale
        scrollView.maximumZoomScale = maxZoomScale * 1.1
    }
}

extension FullScreenContentViewController {
    private func zoomInOrOut(
        at point: CGPoint
    ) {
        var newZoomScale: CGFloat

        if scrollView.zoomScale == scrollView.minimumZoomScale {
            newZoomScale = maxZoomScale
        } else {
            newZoomScale = scrollView.minimumZoomScale
        }

        let size = scrollView.bounds.size

        let width = size.width / newZoomScale
        let height = size.height / newZoomScale

        let x = point.x - (width * 0.5)
        let y = point.y - (height * 0.5)

        let rect = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )

        scrollView.zoom(
            to: rect,
            animated: true
        )
    }

    private func hideCloseActionViewIfNeeded() {
        if contentView.frame.intersects(closeActionView.frame) {
            closeActionView.alpha = 0
        } else {
            closeActionView.alpha = 1
        }
    }
}
