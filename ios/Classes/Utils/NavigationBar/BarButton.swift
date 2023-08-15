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
//  BarButton.swift

import Foundation
import UIKit
import MacaroonUIKit

class BarButton:
    UIButton,
    CornerDrawable {
    
    private let barButtonItem: BarButtonItem
    
    init(barButtonItem: BarButtonItem) {
        self.barButtonItem = barButtonItem
        
        super.init(frame: .zero)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BarButton {
    
    private func configureAppearance() {
        adjustsImageWhenHighlighted = false

        backgroundColor = barButtonItem.backgroundColor

        if let corner = barButtonItem.corner {
            draw(corner: corner)
        }
        
        titleLabel?.font = barButtonItem.title?.font
        setTitle(barButtonItem.title?.text, for: .normal)
        setTitleColor(barButtonItem.title?.textColor, for: .normal)
        setTitleColor(barButtonItem.title?.textColor.withAlphaComponent(0.5), for: .highlighted)
        setImage(barButtonItem.image?.normal, for: .normal)
        
        if let highligtedImage = barButtonItem.image?.highlighted {
            setImage(highligtedImage, for: .highlighted)
        }
        if let disabledImage = barButtonItem.image?.disabled {
            setImage(disabledImage, for: .disabled)
        }
        if let tint = barButtonItem.image?.tintColor {
            tintColor = tint
        }
    }
}

extension BarButton {
    
    private func prepareLayout() {
        switch barButtonItem.size {
        case .compressed(let insets):
            prepareLayoutForCompressedSize(insets: insets)
        case .expanded(let width, let height):
            prepareLayoutForExpandedSize(width: width, height: height)
        case .aligned(let size):
            prepareLayoutForAlignedSize(size)
        case .explicit(let size):
            prepareLayoutForExplicitSize(size)
        }
    }
    
    private func prepareLayoutForCompressedSize(insets: BarButtonCompressedSizeInsets) {
        contentEdgeInsets = insets.contentInsets
        titleEdgeInsets = insets.titleInsets ?? .zero
        imageEdgeInsets = insets.imageInsets ?? .zero
    }
    
    private func prepareLayoutForExpandedSize(width: BarButtonExpandedSizeMetric, height: BarButtonExpandedSizeMetric) {
        var contentInsets = UIEdgeInsets.zero
        var titleInsets = UIEdgeInsets.zero
        var imageInsets = UIEdgeInsets.zero
        
        switch width {
        case .equal(let aWidth):
            snp.makeConstraints { maker in
                maker.width.equalTo(aWidth)
            }
        case .dynamicWidth(let insets):
            contentInsets.left = insets.contentInsets.left
            contentInsets.right = insets.contentInsets.right
            insets.titleInsets.map {
                titleInsets.left = $0.left
                titleInsets.right = $0.right
            }
            insets.imageInsets.map {
                imageInsets.left = $0.left
                imageInsets.right = $0.right
            }
        case .dynamicHeight:
            break
        }
        switch height {
        case .equal(let aHeight):
            snp.makeConstraints { maker in
                maker.height.equalTo(aHeight)
            }
        case .dynamicWidth:
            break
        case .dynamicHeight(let insets):
            contentInsets.top = insets.contentInsets.top
            contentInsets.bottom = insets.contentInsets.bottom
            insets.titleInsets.map {
                titleInsets.top = $0.top
                titleInsets.bottom = $0.bottom
            }
            insets.imageInsets.map {
                imageInsets.top = $0.top
                imageInsets.bottom = $0.bottom
            }
        }
        
        contentEdgeInsets = contentInsets
        titleEdgeInsets = titleInsets
        imageEdgeInsets = imageInsets
    }
    
    private func prepareLayoutForAlignedSize(_ size: BarButtonAlignedContentSize) {
        snp.makeConstraints { maker in
            maker.size.equalTo(size.explicitSize)
        }
        switch size.alignment {
        case .top:
            contentVerticalAlignment = .top
        case .left:
            contentHorizontalAlignment = .left
        case .bottom:
            contentVerticalAlignment = .bottom
        case .right:
            contentHorizontalAlignment = .right
        }
        contentEdgeInsets = size.insets
    }
    
    private func prepareLayoutForExplicitSize(_ size: CGSize) {
        snp.makeConstraints { maker in
            maker.size.equalTo(size)
        }
    }
}

extension BarButton {
    
    private func linkInteractors() {
        addTarget(self, action: #selector(callInteractor(sender:)), for: .touchUpInside)
    }
    
    @objc
    private func callInteractor(sender: Any) {
        barButtonItem.handler?()
    }
}
