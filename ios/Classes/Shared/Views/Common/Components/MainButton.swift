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
//  MainButton.swift

import UIKit

class MainButton: UIButton {
    private let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configureButton()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainButton {
    private func configureButton() {
        titleLabel?.textAlignment = .center
        setTitleColor(Colors.Button.Primary.text.uiColor, for: .normal)
        setTitleColor(Colors.Button.Primary.disabledText.uiColor, for: .disabled)
        setTitle(title, for: .normal)
        setBackgroundImage(img("bg-main-button"), for: .normal)
        setBackgroundImage(img("bg-main-button-disabled"), for: .disabled)
        titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
    }
}
