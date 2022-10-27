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

//   NavigationBarTitleView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NavigationBarTitleView:
    BaseView,
    MacaroonUIKit.NavigationBarTitleView {
    var title: EditText? {
        get { titleView.editText }
        set { titleView.editText = newValue }
    }
    var titleAlpha: CGFloat {
        get { titleView.alpha }
        set { titleView.alpha = newValue }
    }

    private lazy var titleView = Label()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        addTitle()
    }
}

extension NavigationBarTitleView {
    private func addTitle() {
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}
