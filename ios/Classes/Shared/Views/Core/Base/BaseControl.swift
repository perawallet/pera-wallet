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
//  BaseControl.swift

import UIKit

class BaseControl: UIControl {
    override var isEnabled: Bool {
        didSet {
            changeAppearance()
        }
    }
    override var isSelected: Bool {
        didSet {
            changeAppearance()
        }
    }
    override var isHighlighted: Bool {
        didSet {
            changeAppearance()
        }
    }

    // MARK: Initialization
    init() {
        super.init(frame: .zero)
        setupAccessibility()
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAccessibility() {
        accessibilityIdentifier = String(describing: self)
        isAccessibilityElement = true
    }

    func reconfigureAppearance(for state: State) { }
    func reconfigureAppearance(for touchState: ControlTouchState) { }

    func configureAppearance() {
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }

    func prepareForReuse() { }
    
    @available(iOS 12.0, *)
    func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        reconfigureAppearance(for: .began)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        reconfigureAppearance(for: .began)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        reconfigureAppearance(for: .ended)
    }

    override func cancelTracking(with event: UIEvent?) {
        reconfigureAppearance(for: .ended)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            preferredUserInterfaceStyleDidChange(to: traitCollection.userInterfaceStyle)
        }
    }
}

extension BaseControl {
    private func changeAppearance() {
        if isEnabled {
            if isSelected {
                reconfigureAppearance(for: .selected)
            } else if isHighlighted {
                reconfigureAppearance(for: .highlighted)
            } else {
                reconfigureAppearance(for: .normal)
            }
        } else {
            reconfigureAppearance(for: .disabled)
        }
    }
}

enum ControlTouchState {
    case began
    case ended
}
