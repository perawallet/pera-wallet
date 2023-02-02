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
//   Button.swift

import UIKit
import MacaroonUIKit

/// <todo>
/// Remove `Button` from the project.
final class Button: MacaroonUIKit.Button, TripleShadowDrawable {
    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()

    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()

    private var theme: ButtonTheme?
    private lazy var indicatorView = ViewLoadingIndicator()

    override var isEnabled: Bool {
        didSet {
            customizeBackgroundColor(theme ?? ButtonPrimaryTheme(), isEnabled: isEnabled)
        }
    }

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        drawAppearance(
            secondShadow: secondShadow
        )
        drawAppearance(
            thirdShadow: thirdShadow
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let secondShadow = secondShadow {
            updateOnLayoutSubviews(
                secondShadow: secondShadow
            )
        }

        if let thirdShadow = thirdShadow {
            updateOnLayoutSubviews(
                thirdShadow: thirdShadow
            )
        }
    }

    func customize(_ theme: ButtonTheme) {
        self.theme = theme

        customizeView(theme)
        customizeLabel(theme)
        customizeBackgroundColor(theme, isEnabled: isEnabled)
        customizeShadow(theme)

        addIndicator(theme)
    }

    func prepareLayout(_ layoutSheet: ButtonTheme) {}

    func customizeAppearance(_ styleSheet: ButtonTheme) {}

    func bindData(_ viewModel: ButtonViewModel?) {
        bindTitle(viewModel)
        bindIcon(viewModel)
    }
}

extension Button {
    private func customizeView(_ theme: ButtonTheme) {
        contentEdgeInsets = UIEdgeInsets(theme.contentEdgeInsets)
        layer.draw(corner: theme.corner)
        layer.masksToBounds = true
    }

    private func customizeLabel(_ theme: ButtonTheme) {
        titleLabel?.customizeAppearance(theme.label)
        setTitleColor(theme.titleColorSet[.normal], for: .normal)
        setTitleColor(theme.titleColorSet[.disabled], for: .disabled)
        imageView?.customizeAppearance(theme.icon)
    }

    private func addIndicator(_ theme: ButtonTheme) {
        indicatorView.applyStyle(theme.indicator)

        addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        indicatorView.isHidden = true
    }

    private func customizeShadow(_ theme: ButtonTheme) {
        if let firstShadow = theme.firstShadow {
            drawAppearance(shadow: firstShadow)
        }

        if let secondShadow = theme.secondShadow {
            drawAppearance(secondShadow: secondShadow)
        }

        if let thirdShadow = theme.thirdShadow {
            drawAppearance(thirdShadow: thirdShadow)
        }
    }
}

extension Button {
    private func bindTitle(_ viewModel: ButtonViewModel?) {
        setTitle(viewModel?.title?.string, for: .normal)
    }

    private func bindIcon(_ viewModel: ButtonViewModel?) {
        guard viewModel?.iconSet != nil else {
            return
        }

        setImage(viewModel?.iconSet?[.normal], for: .normal)
        setImage(viewModel?.iconSet?[.disabled], for: .disabled)
    }
}

extension Button {
    func startLoading() {
        guard !indicatorView.isAnimating else {
            return
        }

        indicatorView.isHidden = false
        isEnabled = false
        titleLabel?.layer.opacity = .zero
        imageView?.layer.opacity = .zero
        indicatorView.startAnimating()
    }

    func stopLoading() {
        guard indicatorView.isAnimating else {
            return
        }

        indicatorView.isHidden = true
        isEnabled = true
        titleLabel?.layer.opacity = 1
        imageView?.layer.opacity = 1
        indicatorView.stopAnimating()
    }
}

extension Button {
    private func customizeBackgroundColor(_ theme: ButtonTheme, isEnabled: Bool) {
        let backgroundColor = isEnabled ? theme.backgroundColorSet[.normal] : theme.backgroundColorSet[.disabled]
        customizeBaseAppearance(backgroundColor: backgroundColor)
    }
}
