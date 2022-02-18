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
//  CGFloat+Additions.swift

import CoreGraphics
import UIKit

extension CGFloat {
    var isIntrinsicMetric: Bool {
        return self != UIView.noIntrinsicMetric
    }
    
    var upper: CGFloat {
        return rounded(.up)
    }
    
    var lower: CGFloat {
        return rounded(.down)
    }
    
    var nearest: CGFloat {
        return rounded()
    }
}
