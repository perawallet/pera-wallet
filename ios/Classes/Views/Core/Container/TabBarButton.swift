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
//  TabBarButton.swift

import UIKit

class TabBarButton: UIControl {
    
    var badge: String? {
        get {
            return badgeView.currentTitle
        }
        set {
            set(badge: newValue, animated: true)
        }
    }

    override var isEnabled: Bool {
        didSet {
            contentView.isEnabled = isEnabled
        }
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.isSelected = isSelected
        }
    }

    let barButtonItem: TabBarButtonItemConvertible

    private(set) lazy var contentView = AlignedButton()
    
    private lazy var badgeView = UIButton()

    init(_ barButtonItem: TabBarButtonItemConvertible) {
        self.barButtonItem = barButtonItem
        super.init(frame: .zero)
        customizeAppearance()
        prepareLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return contentView.frame.contains(point)
    }
}

extension TabBarButton {
    private func customizeAppearance() {
        customizeContentAppearance()
        customizeBadgeAppearance()
    }

    private func prepareLayout() {
        addContent()
    }
}

extension TabBarButton {
    private func customizeContentAppearance() {
        contentView.setImage(barButtonItem.icon, for: .normal)
        contentView.setImage(barButtonItem.selectedIcon, for: .selected)
        contentView.isUserInteractionEnabled = false
        contentView.adjustsImageWhenHighlighted = false
        contentView.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.titleLabel?.minimumScaleFactor = 0.5
    }
    
    private func addContent() {
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.width.greaterThanOrEqualTo(44.0).priority(.high)
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
            maker.leading.greaterThanOrEqualToSuperview()
            maker.bottom.equalToSuperview()
            maker.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension TabBarButton {
    func set(badge: String?, animated: Bool) {
        if badge == nil {
            removeBadge(animated: animated)
            return
        }
        badgeView.setTitle(badge, for: .normal)
        badgeView.invalidateIntrinsicContentSize()
        addBadge(animated: animated)
    }
    
    private func customizeBadgeAppearance() {
        if let badgeIcon = barButtonItem.badgeIcon {
            badgeView.setImage(badgeIcon, for: .normal)
            badgeView.isUserInteractionEnabled = false
        }
    }
    
    private func addBadge(animated: Bool) {
        if badgeView.isDescendant(of: self) { return }

        addSubview(badgeView)
        badgeView.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: 4.0)
        badgeView.snp.makeConstraints { maker in
            maker.width.greaterThanOrEqualTo(badgeView.snp.height)

            if let imageView = contentView.imageView {
                maker.centerX.equalTo(imageView.snp.trailing).offset(barButtonItem.badgePositionAdjustment?.x ?? 0.0)
                maker.centerY.equalTo(imageView.snp.top).offset(barButtonItem.badgePositionAdjustment?.y ?? 0.0)
            } else {
                maker.leading.equalTo(contentView.snp.centerX)
                maker.bottom.equalTo(contentView.snp.centerY)
            }
        }

        if animated {
            animateBadge(onScreen: true) { _ in }
        }
    }

    private func removeBadge(animated: Bool) {
        if !animated {
            badgeView.removeFromSuperview()
            return
        }
        animateBadge(onScreen: false) { [weak self] _ in
            self?.badgeView.removeFromSuperview()
        }
    }

    private func animateBadge(onScreen: Bool, onCompleted completion: @escaping (UIViewAnimatingPosition) -> Void) {
        let offScreenTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        if onScreen {
            badgeView.transform = offScreenTransform
            badgeView.layoutIfNeeded()
        }
        let animator = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 0.75) {
            self.badgeView.transform = onScreen ? .identity : offScreenTransform
        }
        animator.addCompletion(completion)
        animator.startAnimation()
    }
}
