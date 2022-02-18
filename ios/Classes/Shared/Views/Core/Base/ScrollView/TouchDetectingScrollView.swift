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
//  TouchDetectingScrollView.swift

import UIKit

protocol TouchDetectingScrollViewDelegate: NSObjectProtocol {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint)
}

class TouchDetectingScrollView: UIScrollView {
    
    weak var touchDetectingDelegate: TouchDetectingScrollViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        touchDetectingDelegate?.scrollViewDidDetectTouchEvent(scrollView: self, in: point)
        return super.hitTest(point, with: event)
    }
}
