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
//  Checkbox.swift

import UIKit

class Checkbox: BaseControl {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-checkbox"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func reconfigureAppearance(for state: State) {
        switch state {
        case .highlighted, .selected:
            imageView.image = img("icon-checkbox-checked")
        case .normal:
            imageView.image = img("icon-checkbox")
        default:
            return
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        let imageViewGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageView.addGestureRecognizer(imageViewGesture)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    @objc
    private func didTap() {
        sendActions(for: .allTouchEvents)
    }
}
