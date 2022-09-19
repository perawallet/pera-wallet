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
//  BaseView.swift

import UIKit

class BaseView: UIView {
    
    var endsEditingAfterTouches: Bool {
        return false
    }

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
        backgroundColor = Colors.Defaults.background.uiColor
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }
    
    @available(iOS 12.0, *)
    func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if endsEditingAfterTouches {
            endEditing(true)
        }
        
        return super.hitTest(point, with: event)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            preferredUserInterfaceStyleDidChange(to: traitCollection.userInterfaceStyle)
        }
    }
}
