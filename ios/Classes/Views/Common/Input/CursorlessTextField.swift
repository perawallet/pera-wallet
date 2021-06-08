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
//  CursorlessTextField.swift

import UIKit

class CursorlessTextField: UITextField {
    
    weak var cursorlessTextFieldDelegate: CursorlessTextFieldDelegate?
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        cursorlessTextFieldDelegate?.cursorlessTextFieldDidDeleteBackward(self)
    }
}

extension UITextField {
    func setLeftPadding(amount point: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: point, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPadding(amount point: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: point, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}

protocol CursorlessTextFieldDelegate: class {
    func cursorlessTextFieldDidDeleteBackward(_ cursorlessTextField: CursorlessTextField)
}
