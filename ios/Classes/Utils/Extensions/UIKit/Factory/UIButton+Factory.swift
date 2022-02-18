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
//  UIButton+Factory.swift

import UIKit

extension UIButton {
    
    func withImage(_ image: UIImage?) -> UIButton {
        setImage(image, for: .normal)
        return self
    }
    
    func withBackgroundImage(_ image: UIImage?) -> UIButton {
        setBackgroundImage(image, for: .normal)
        return self
    }
    
    func withFont(_ font: UIFont) -> UIButton {
        titleLabel?.font = font
        return self
    }
    
    func withTitleColor(_ textColor: UIColor) -> UIButton {
        setTitleColor(textColor, for: .normal)
        return self
    }
    
    func withTitle(_ text: String) -> UIButton {
        setTitle(text, for: .normal)
        return self
    }
    
    func withAttributedTitle(_ text: NSAttributedString?) -> UIButton {
        setAttributedTitle(text, for: .normal)
        return self
    }
    
    func withAlignment(_ alignment: NSTextAlignment) -> UIButton {
        titleLabel?.textAlignment = alignment
        return self
    }
    
    func withTintColor(_ color: UIColor) -> UIButton {
        tintColor = color
        return self
    }
    
    func withImageEdgeInsets(_ edgeInsets: UIEdgeInsets) -> UIButton {
        imageEdgeInsets = edgeInsets
        return self
    }
    
    func withTitleEdgeInsets(_ edgeInsets: UIEdgeInsets) -> UIButton {
        titleEdgeInsets = edgeInsets
        return self
    }
    
    func withBackgroundColor(_ color: UIColor) -> UIButton {
        backgroundColor = color
        return self
    }
}
