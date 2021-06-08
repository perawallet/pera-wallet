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
//  LottieImageView.swift

import Lottie

class LottieImageView: BaseView {

    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.contentMode = .scaleAspectFit
        return animationView
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(animationView)
    }
}

extension LottieImageView {
    func setAnimation(_ animation: String) {
        let animation = Animation.named(animation)
        animationView.animation = animation
    }

    func show(with configuration: LottieConfiguration) {
        animationView.play(fromProgress: configuration.from, toProgress: configuration.to, loopMode: configuration.loopMode)
    }

    func stop() {
        animationView.stop()
    }
}

struct LottieConfiguration {
    var from: AnimationProgressTime = 0
    var to: AnimationProgressTime = 1
    var loopMode: LottieLoopMode = .playOnce
}
