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
//  PasswordInputCircle.swift

import UIKit
import MacaroonUIKit
import Foundation

final class PasswordInputCircleView: ImageView, ViewComposable {
    private lazy var theme = PasswordInputCircleViewTheme()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(theme.size)
    }
    
    var state: State = .empty {
        didSet {
            render(state)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func customize(_ theme: PasswordInputCircleViewTheme) {
        image = theme.imageSet[.normal]
        layer.draw(corner: theme.corner)
        customizeBaseAppearance(contentMode: theme.contentMode)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PasswordInputCircleView {
    private func render(_ state: State) {
        switch state {
        case .empty:
            image = theme.imageSet[.normal]
        case .error:
            image = theme.imageSet[.selected]?.withRenderingMode(.alwaysTemplate)
            tintColor = theme.negativeTintColor.uiColor
        case .filled:
            image = theme.imageSet[.selected]
        }
    }
}

extension PasswordInputCircleView {
    enum State {
        case empty
        case filled
        case error
    }
}
