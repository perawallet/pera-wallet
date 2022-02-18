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
//  AlignedButton.swift

import UIKit

class AlignedButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        if currentImage == nil && currentTitle == nil {
            return .zero
        }
        return super.intrinsicContentSize
    }

    private let style: Style

    required init(_ style: Style = .none) {
        self.style = style
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.imageRect(forContentRect: contentRect)

        if currentTitle == nil {
            return rect
        }
        
        switch style {
        case .none:
            return rect
        case .imageAtTop(let spacing):
            let titleHeight = super.titleRect(forContentRect: contentRect).height
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = ((contentRect.height - (rect.height + spacing + titleHeight)) / 2.0).rounded() + contentEdgeInsets.top
            return rect
        case .imageAtTopmost(let padding, _):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = contentRect.minY + padding + contentEdgeInsets.top
            return rect
        case .imageAtLeft(let spacing):
            rect.origin.x -= (spacing / 2.0).rounded()
            return rect
        case .imageAtLeftmost(let padding, _):
            rect.origin.x = contentRect.width - (padding + contentEdgeInsets.left)
            return rect
        case .imageAtRight(let spacing):
            let titleWidth = super.titleRect(forContentRect: contentRect).width
            rect.origin.x = rect.minX + titleWidth + (spacing / 2.0).rounded() + contentEdgeInsets.left
            return rect
        case .imageAtRightmost(let padding, _):
            rect.origin.x = contentRect.width - (rect.width + padding + contentEdgeInsets.right)
            return rect
        case .titleAtBottommost(_, let imageAdjustmentY):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = ((contentRect.height - rect.height) / 2.0).rounded() + imageAdjustmentY + contentEdgeInsets.top
            return rect
        }
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.titleRect(forContentRect: contentRect)

        if currentImage == nil {
            return rect
        }
        
        switch style {
        case .none:
            return rect
        case .imageAtTop(let spacing):
            let imageHeight = super.imageRect(forContentRect: contentRect).height
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = contentRect.height -
                ((contentRect.height - (imageHeight + spacing + rect.height)) / 2.0).rounded() -
                (rect.height + contentEdgeInsets.bottom)
            return rect
        case .imageAtTopmost(_, let titleAdjustmentY):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = ((contentRect.height - rect.height) / 2.0).rounded() + titleAdjustmentY + contentEdgeInsets.top
            return rect
        case .imageAtLeft(let spacing):
            rect.origin.x += (spacing / 2.0).rounded()
            return rect
        case .imageAtLeftmost(_, let titleAdjustmentX):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + titleAdjustmentX + contentEdgeInsets.left
            return rect
        case .imageAtRight(let spacing):
            let imageWidth = super.imageRect(forContentRect: contentRect).width
            rect.origin.x = ((contentRect.width - (rect.width + spacing + imageWidth)) / 2.0).rounded() + contentEdgeInsets.left
            return rect
        case .imageAtRightmost(_, let titleAdjustmentX):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + titleAdjustmentX + contentEdgeInsets.left
            return rect
        case .titleAtBottommost(let padding, _):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = contentRect.maxY - (rect.height + padding + contentEdgeInsets.bottom)
            return rect
        }
    }
}

extension AlignedButton {
    enum Style {
        case none
        case imageAtTop(spacing: CGFloat)
        /// <note> Padding equals to the inset from top for the image while the title is centered.
        case imageAtTopmost(padding: CGFloat, titleAdjustmentY: CGFloat)
        case imageAtLeft(spacing: CGFloat)
        /// <note> Padding equals to the inset from left for the image while the title is centered offset by titleAdjustmentX.
        case imageAtLeftmost(padding: CGFloat, titleAdjustmentX: CGFloat)
        case imageAtRight(spacing: CGFloat)
        /// <note> Padding equals to the inset from right for the image while the title is centered offset by titleAdjustmentX.
        case imageAtRightmost(padding: CGFloat, titleAdjustmentX: CGFloat)
        case titleAtBottommost(padding: CGFloat, imageAdjustmentY: CGFloat)
    }
}
