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
//  SegmentItem.swift

import BetterSegmentedControl
import UIKit

class SegmentItem: BetterSegmentedControlSegment {
    
    var intrinsicContentSize: CGSize?

    private let text: String
    private let image: UIImage?
    
    init(text: String, image: UIImage? = nil) {
        self.text = text
        self.image = image
    }
        
    lazy var normalView: UIView = {
        createView(withText: text, image: image)
    }()
    
    lazy var selectedView: UIView = {
        createView(withText: text, image: image)
    }()
    
    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.font(withWeight: .medium(size: 14.0))
        label.textColor = Colors.Text.primary
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }
    
    private func createImage(with image: UIImage?) -> UIImageView {
        UIImageView(image: image)
    }
    
    private func createView(withText text: String, image: UIImage? = nil) -> UIView {
        let containerView = UIView()
        let label = createLabel(with: text)
        
        let isImageEnabled = image != nil
        
        let centerXOffset = isImageEnabled ? 24.0 : 0.0
        
        containerView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.centerX.equalToSuperview().inset(centerXOffset)
        }
        
        guard isImageEnabled else {
            return containerView
        }
        
        let imageView = createImage(with: image)
        
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.leading.equalTo(label.snp.trailing).offset(8)
            maker.centerY.equalTo(label)
        }
        
        return containerView
    }
}
