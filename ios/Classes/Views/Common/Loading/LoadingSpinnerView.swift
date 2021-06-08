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
//  LoadingSpinnerView.swift

import UIKit
import Lottie

class LoadingSpinnerView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let viewSize = CGSize(width: 22.0, height: 22.0)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.viewSize
    }
    
    private lazy var loadingAnimationView: AnimationView = {
        let loadingAnimationView = AnimationView()
        loadingAnimationView.contentMode = .scaleAspectFit
        let animation = Animation.named("LoadingAnimation")
        loadingAnimationView.animation = animation
        return loadingAnimationView
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        addSubview(loadingAnimationView)
        
        loadingAnimationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: API

extension LoadingSpinnerView {
    func updateColor(to color: UIColor) {
        guard let rgba = color.rgba else {
            return
        }

        let newColor = Color(r: Double(rgba.red), g: Double(rgba.green), b: Double(rgba.blue), a: Double(rgba.alpha))
        let colorValueProvider = ColorValueProvider(newColor)

        // Set value provider from related animation keypath
        // Get keypath with function: AnimationView.logHierarchyKeypaths()
        // https://swiftsenpai.com/development/lottie-value-providers/
        let keyPath = AnimationKeypath(keypath: "spinner Outlines.Group 1.Stroke 1.Color")
        loadingAnimationView.setValueProvider(colorValueProvider, keypath: keyPath)
    }

    func show() {
        loadingAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }
    
    func stop() {
        loadingAnimationView.stop()
    }
}
