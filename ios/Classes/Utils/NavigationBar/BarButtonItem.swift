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
//  BarButtonItem.swift

import Foundation
import UIKit
import MacaroonUIKit

protocol BarButtonItem {
    
    typealias TitleContent = BarButtonItemTitleContent
    typealias ImageContent = BarButtonItemImageContent
    typealias Size = BarButtonSize

    var backgroundColor: UIColor? { get }
    var corner: Corner? { get }
    var title: TitleContent? { get }
    var image: ImageContent? { get }
    var size: Size { get }
    var handler: EmptyHandler? { get set }
    
    /// Returns nil if the bar button item cannot be configured as a back/dismiss.
    static func back() -> Self?
    static func dismiss() -> Self?
}

extension BarButtonItem {
    var title: TitleContent? {
        return nil
    }
    
    var image: ImageContent? {
        return nil
    }
    
    var size: Size {
        return .explicit(CGSize(width: 30.0, height: 30.0))
    }
    
    static func back() -> Self? {
        return nil
    }
    
    static func dismiss() -> Self? {
        return nil
    }
}

struct BarButtonItemTitleContent {
    
    let text: String
    let textColor: UIColor
    let font: UIFont
}

struct BarButtonItemImageContent {
    
    let normal: UIImage
    let highlighted: UIImage?
    let disabled: UIImage?
    let tintColor: UIColor?
    
    init(
        normal: UIImage,
        highlighted: UIImage? = nil,
        disabled: UIImage? = nil,
        tintColor: UIColor? = nil
    ) {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.tintColor = tintColor
    }
}

struct BarButtonCompressedSizeInsets {
    
    let contentInsets: UIEdgeInsets
    let titleInsets: UIEdgeInsets?
    let imageInsets: UIEdgeInsets?
    
    init(contentInsets: UIEdgeInsets = .zero, titleInsets: UIEdgeInsets? = nil, imageInsets: UIEdgeInsets? = nil) {
        self.contentInsets = contentInsets
        self.titleInsets = titleInsets
        self.imageInsets = imageInsets
    }
}

struct BarButtonExpandedSizeHorizontalInsets {
    
    typealias Insets = (left: CGFloat, right: CGFloat)
    
    let contentInsets: Insets
    let titleInsets: Insets?
    let imageInsets: Insets?
    
    init(contentInsets: Insets, titleInsets: Insets? = nil, imageInsets: Insets? = nil) {
        self.contentInsets = contentInsets
        self.titleInsets = titleInsets
        self.imageInsets = imageInsets
    }
}

struct BarButtonExpandedSizeVerticalInsets {
    
    typealias Insets = (top: CGFloat, bottom: CGFloat)
    
    let contentInsets: Insets
    let titleInsets: Insets?
    let imageInsets: Insets?
    
    init(contentInsets: Insets, titleInsets: Insets? = nil, imageInsets: Insets? = nil) {
        self.contentInsets = contentInsets
        self.titleInsets = titleInsets
        self.imageInsets = imageInsets
    }
}

struct BarButtonAlignedContentSize {
    
    typealias Alignment = BarButtonAlignedContentAlignment
    
    let explicitSize: CGSize
    let alignment: Alignment
    let insets: UIEdgeInsets
    
    init(explicitSize: CGSize, alignment: Alignment = .left, insets: UIEdgeInsets = .zero) {
        self.explicitSize = explicitSize
        self.alignment = alignment
        self.insets = insets
    }
}

enum BarButtonExpandedSizeMetric {
    case equal(CGFloat)
    /// DynamicDimension refers to width, parameters reflect left&right insets,
    /// likewise it refers to height, parameters reflect top&bottom insets.
    case dynamicWidth(BarButtonExpandedSizeHorizontalInsets)
    case dynamicHeight(BarButtonExpandedSizeVerticalInsets)
}

enum BarButtonAlignedContentAlignment {
    case top
    case left
    case bottom
    case right
}

enum BarButtonSize {
    case compressed(BarButtonCompressedSizeInsets)
    case expanded(width: BarButtonExpandedSizeMetric, height: BarButtonExpandedSizeMetric)
    case aligned(BarButtonAlignedContentSize)
    case explicit(CGSize)
}
