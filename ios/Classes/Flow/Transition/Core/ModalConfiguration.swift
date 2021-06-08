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
//  ModalConfiguration.swift

import UIKit

struct ModalConfiguration {
    
    let animationMode: AnimationMode
    let dismissMode: DismissMode
    
    init(animationMode: AnimationMode, dismissMode: DismissMode = .none) {
        self.animationMode = animationMode
        self.dismissMode = dismissMode
    }
}

extension ModalConfiguration {
    enum AnimationMode {
        case normal(duration: TimeInterval)
        case spring(duration: TimeInterval, damping: CGFloat, velocity: CGFloat)
    }
    
    enum DismissMode {
        case none
        case backgroundTouch
        case scroll
    }
}

extension ModalConfiguration.AnimationMode {
    typealias AfterAnimationHandler = (Bool) -> Void
    
    func animate(
        _ animations: @escaping EmptyHandler,
        before beforeAnimationsHandler: EmptyHandler? = nil,
        after afterAnimationsHandler: AfterAnimationHandler? = nil
    ) {
        beforeAnimationsHandler?()
        
        switch self {
        case .normal(let duration):
            UIView.animate(
                withDuration: duration,
                animations: {
                    animations()
                },
                completion: { isCompleted in
                    afterAnimationsHandler?(isCompleted)
                }
            )
        case .spring(let duration, let damping, let velocity):
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: velocity,
                options: [],
                animations: {
                    animations()
                },
                completion: { isCompleted in
                    afterAnimationsHandler?(isCompleted)
                }
            )
        }
    }
}

extension ModalConfiguration.DismissMode {
    var isCancelled: Bool {
        return self == .none
    }
}
