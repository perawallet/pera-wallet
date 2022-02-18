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
//  Notification+Keyboard.swift

import UIKit

extension Notification {
    
    var keyboardBeginFrame: CGRect? {
        return userInfo?[UIResponder.keyboardFrameBeginUserInfoKey].flatMap { ($0 as? NSValue)?.cgRectValue } ?? nil
    }
    
    var keyboardEndFrame: CGRect? {
        return userInfo?[UIResponder.keyboardFrameEndUserInfoKey].flatMap { ($0 as? NSValue)?.cgRectValue } ?? nil
    }
    
    var keyboardHeight: CGFloat? {
        return keyboardEndFrame?.height
    }
    
    var keyboardAnimationDuration: TimeInterval {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey].flatMap { $0 as? TimeInterval } ?? 0.25    }
    
    var keyboardAnimationCurve: UIView.AnimationCurve {
        guard let animationCurveRaw = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
            return .linear
        }
        
        return UIView.AnimationCurve(rawValue: animationCurveRaw) ?? .linear
    }
}
