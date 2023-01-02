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
//  LottieImageView.swift

import MacaroonUIKit
import Lottie
import UIKit

final class LottieImageView: View {
    var isAnimationPlaying: Bool {
        return animationView.isAnimationPlaying
    }

    private lazy var animationView = LottieAnimationView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addAnimationView()
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension LottieImageView {
    func addAnimationView() {
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore

        prepareWholeScreenLayoutFor(animationView)
    }
}

extension LottieImageView {
    func setAnimation(_ jsonName: String) {
        animationView.animation = LottieAnimation.named(jsonName)
    }

    func play(with configuration: LottieImageView.Configuration) {
        animationView.play(fromProgress: configuration.from, toProgress: configuration.to, loopMode: configuration.loopMode)
    }

    func play() {
        animationView.play()
    }

    func pause() {
        animationView.pause()
    }

    func stop() {
        animationView.stop()
    }
}

extension LottieImageView {
    struct Configuration {
        var from: AnimationProgressTime = 0
        var to: AnimationProgressTime = 1
        var loopMode: LottieLoopMode = .loop
    }
}
